package Armadito::Agent;

use 5.008000;
use strict;
use warnings;
use English qw(-no_match_vars);
use UNIVERSAL::require;

use Readonly;
Readonly my $LOG_DEBUG2  => 5;
Readonly my $LOG_DEBUG   => 4;
Readonly my $LOG_INFO    => 3;
Readonly my $LOG_WARNING => 2;
Readonly my $LOG_ERROR   => 1;
Readonly my $LOG_NONE    => 0;

require Exporter;

use Armadito::Agent::Config;
use Armadito::Agent::Storage;
use Armadito::Agent::Antivirus;
use Armadito::Agent::Logger;
use Armadito::Agent::Tools::Fingerprint qw(getFingerprint);

our $VERSION = "0.1.0_02";
my @supported_antiviruses = ("Armadito");
my @supported_tasks       = ( "State", "Enrollment", "Getjobs", "Runjobs", "Alerts", "Scan" );
my @superuser_tasks       = ( "Enrollment", "Getjobs", "Runjobs" );

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		status  => 'unknown',
		confdir => $params{confdir},
		datadir => $params{datadir},
		libdir  => $params{libdir},
		vardir  => $params{vardir},
		sigterm => $params{sigterm},
		targets => [],
		tasks   => []
	};
	bless $self, $class;

	return $self;
}

sub _validateConfiguration {
	my ( $self, %params ) = @_;

	$self->isAVSupported( $self->{config}->{armadito}->{antivirus} )
		or die "Unsupported Antivirus. Use --list-avs to see which antiviruses are supported.";

	if ( $params{options}->{task} ) {
		$self->isTaskSupported( $params{options}->{task} )
			or die "Unsupported Task. Use --list-tasks to see which tasks are supported.";
	}
}

sub init {
	my ( $self, %params ) = @_;

	$self->_getFusionSetup();

	$self->{config} = Armadito::Agent::Config->new(
		armadito_confdir => $self->{confdir},
		fusion_confdir   => $self->{fusion_confdir},
		options          => $params{options}
	);

	my $verbosity
		= $self->{config}->{armadito}->{debug} && $self->{config}->{armadito}->{debug} == 1 ? $LOG_DEBUG
		: $self->{config}->{armadito}->{debug} && $self->{config}->{armadito}->{debug} == 2 ? $LOG_DEBUG2
		:                                                                                     $LOG_INFO;

	$self->{config}->{armadito}->{server} = $params{options}->{server}
		if ( defined( $params{options}->{server} ) );

	$self->_validateConfiguration(%params);

	$self->{logger} = Armadito::Agent::Logger->new(
		config    => $self->{config}->{armadito},
		backends  => $self->{config}->{armadito}->{logger},
		verbosity => $verbosity
	);

	$self->{fusion_storage} = Armadito::Agent::Storage->new(
		logger    => $self->{logger},
		directory => $self->{fusion_vardir}
	);
	$self->{armadito_storage} = Armadito::Agent::Storage->new(
		logger    => $self->{logger},
		directory => $self->{vardir}
	);

	$self->{job_priority} = $params{options}->{job_priority} ? $params{options}->{job_priority} : -1;

	$self->{agent_id} = 0;
	$self->{fusionid} = "unknown";
	$self->_getFusionId();
	$self->_getArmaditoId();

	$self->{fingerprint} = getFingerprint();

	my $class = "Armadito::Agent::Antivirus::$self->{config}->{armadito}->{antivirus}";
	$class->require();
	$self->{antivirus} = $class->new();
}

sub _getLinuxFusionSetupDir {
	my ( $res, $dirlabel ) = @_;

	if ( $res =~ /$dirlabel: (\S+)/ms ) {
		return $1;
	}
	die "$dirlabel not found when parsing fusioninventory-agent --setup.";
}

sub _getWindowsFusionSetupDir {
	my $Registry;
	Win32::TieRegistry->require();
	Win32::TieRegistry->import(
		Delimiter   => '/',
		ArrayValues => 0,
		TiedRef     => \$Registry
	);

	my $machKey = $Registry->Open(
		'LMachine',
		{
			Access => Win32::TieRegistry::KEY_READ()
		}
	) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

	my $uninstallValues = $machKey->{'SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/FusionInventory-Agent'};
	die "FusionInventory-Agent InstallLocation registry key not found. Please install FusionInventory-Agent (2.3.17+)"
		unless $uninstallValues;

	my $installLocation = $uninstallValues->{'/InstallLocation'};
	die "FusionInventory-Agent InstallLocation registry key not found. Please install FusionInventory-Agent (2.3.17+)"
		unless $installLocation;

	return $installLocation;
}

sub _getFusionSetup {
	my ($self) = @_;
	if ( $OSNAME ne "MSWin32" ) {
		my $res       = `fusioninventory-agent --setup 2>&1`;
		my $exitvalue = `echo -n $?`;
		die
			"Unable to get fusioninventory-agent setup. Please, be sure you have correctly installed fusioninventory agent.\n"
			if ( $exitvalue != 0 );
		$self->{fusion_datadir} = _getLinuxFusionSetupDir( $res, "datadir" );
		$self->{fusion_vardir}  = _getLinuxFusionSetupDir( $res, "vardir" );
		$self->{fusion_confdir} = _getLinuxFusionSetupDir( $res, "confdir" );
		$self->{fusion_libdir}  = _getLinuxFusionSetupDir( $res, "libdir" );
	}
	else {
		my $fusion_setupdir = _getWindowsFusionSetupDir();
		$self->{fusion_datadir} = $fusion_setupdir . "\\share";
		$self->{fusion_vardir}  = $fusion_setupdir . "\\var";
		$self->{fusion_libdir}  = $fusion_setupdir . "\\perl\\agent";
		$self->{fusion_confdir} = $fusion_setupdir . "\\etc";
	}
}

sub _getFusionId {
	my ($self) = @_;

	my $data = $self->{fusion_storage}->restore( name => 'FusionInventory-Agent' );

	$self->{fusionid} = $data->{deviceid} if $data->{deviceid};
}

sub _getArmaditoId {
	my ($self) = @_;

	my $data = $self->{armadito_storage}->restore( name => 'Armadito-Agent' );

	$self->{agent_id} = $data->{agent_id} if $data->{agent_id};
}

sub _storeArmaditoId {
	my ($self) = @_;

	$self->{armadito_storage}->save(
		name => 'Armadito-Agent',
		data => {
			agent_id => $self->{agent_id},
		}
	);
}

sub isAVSupported {
	my ( $self, $antivirus ) = @_;
	foreach (@supported_antiviruses) {
		if ( $antivirus eq $_ ) {
			return 1;
		}
	}
	return 0;
}

sub isTaskSupported {
	my ( $self, $task ) = @_;
	foreach (@supported_tasks) {
		if ( $task eq $_ ) {
			return 1;
		}
	}
	return 0;
}

sub displaySupportedTasks {
	my ($self) = @_;
	print "List of supported tasks :\n";
	foreach (@supported_tasks) {
		print $_. "\n";
	}
}

sub displaySupportedAVs {
	my ($self) = @_;
	print "List of supported antiviruses :\n";
	foreach (@supported_antiviruses) {
		print $_. "\n";
	}
}

1;
__END__
=head1 NAME

Armadito::Agent - Armadito Agent

=head1 VERSION

0.1.0_02

=head1 DESCRIPTION

Agent interfacing between Armadito Antivirus and Armadito plugin for GLPI for Windows and Linux.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<datadir>

the read-only data directory.

=item I<vardir>

the read-write data directory.

=item I<options>

the options to use.

=back

=head2 init()

Initialize the agent.

=head2 isAVSupported($antivirus)

Returns true if given antivirus is supported by the current version of the agent.

=head2 isTaskSupported($task)

Returns true if given task is supported by the current version of the agent.

=head2 displaySupportedTasks()

Display all currently supported tasks to stdout.

=head2 displaySupportedAVs()

Display all currently supported Antiviruses to stdout.

=head1 SEE ALSO

=over 4

=item * L<http://armadito-glpi.readthedocs.io/en/dev/>

Armadito for GLPI online documentation.

=item * L<https://github.com/armadito>

Armadito organization on github.

=item * L<http://www.glpi-project.org/>

GLPI Project main page.

=back

=cut

=head1 AUTHOR

vhamon, E<lt>vhamon@teclib.comE<gt>

=head1 COPYRIGHTS

Copyright (C) 2006-2010 OCS Inventory contributors
Copyright (C) 2010-2012 FusionInventory Team
Copyright (C) 2011-2016 Teclib'

=head1 LICENSE

This software is licensed under the terms of GPLv2+, see LICENSE file for
details.

=cut
