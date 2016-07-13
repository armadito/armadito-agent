package Armadito::Agent;

use 5.008000;
use strict;
use warnings;

require Exporter;

use Armadito::Agent::Config;
use Armadito::Agent::Storage;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = "0.0.3_03";
my @supported_antiviruses = ("Armadito");
my @supported_tasks = ("State","Enrollment","Getjobs");

sub new {
    my ($class, %params) = @_;

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

sub init {
    my ($self, %params) = @_;

	$self->_getFusionSetup();

    $self->{config} = Armadito::Agent::Config->new(
		armadito_confdir => $self->{confdir},
		fusion_confdir => $self->{fusion_confdir},
		options => $params{options}
    );

	$self->{logger} = FusionInventory::Agent::Logger->new(backends => ['Syslog', 'Stderr']);

	$self->{storage} = Armadito::Agent::Storage->new(
        logger    => $self->{logger},
        directory => $self->{fusion_vardir}
    );

	$self->_getFusionId();
}

sub _getFusionSetupDir {
	my ($res, $dirlabel) = @_;

	if($res =~ /$dirlabel: (\S+)/ms){
		return $1;
	}

	die "$dirlabel not found when parsing fusioninventory-agent --setup.";
}

sub _getFusionSetup {
	my ($self) = @_;

	my $res = `fusioninventory-agent --setup 2>&1`;
	my $exitvalue = `echo -n $?`;
	die "Unable to get fusioninventory-agent setup. Please, be sure you have correctly installed fusioninventory agent.\n" if($exitvalue != 0);

	$self->{fusion_datadir} = _getFusionSetupDir($res, "datadir");
	$self->{fusion_vardir} = _getFusionSetupDir($res, "vardir");
	$self->{fusion_confdir} = _getFusionSetupDir($res, "confdir");
	$self->{fusion_libdir} = _getFusionSetupDir($res, "libdir");
}

sub _getFusionId {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => 'FusionInventory-Agent');

    $self->{fusionid} = $data->{deviceid} if $data->{deviceid};
}

sub isAVSupported {
	my ($self, $antivirus) = @_;
    foreach (@supported_antiviruses) {
	  if( $antivirus eq $_ ) {
		return 1;
	  }
	}
	return 0;
}

sub isTaskSupported {
	my ($self, $task) = @_;
    foreach (@supported_tasks) {
	  if( $task eq $_ ) {
		return 1;
	  }
	}
	return 0;
}

sub displaySupportedTasks {
	my ($self) = @_;
	print "List of supported tasks :\n";
	foreach(@supported_tasks) {
		print $_."\n";
	}
}

sub displaySupportedAVs {
	my ($self) = @_;
	print "List of supported antiviruses :\n";
	foreach(@supported_antiviruses) {
		print $_."\n";
	}
}
1;
__END__
=head1 NAME

Armadito::Agent - Armadito Agent

=head1 VERSION

0.0.3_03

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

=item * L<http://armadito-av.readthedocs.io/en/latest/>

Armadito online documentation.

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
