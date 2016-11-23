package Armadito::Agent::Antivirus::Eset::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';

use Data::Dumper;
use Try::Tiny;
use IPC::System::Simple qw(capture);

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);
	$self->_validateScanObj( $self->{job}->{obj} );

	return $self;
}

sub _validateScanObj {
	my ( $self, $scanobj ) = @_;

	die "undefined scan_type."    if ( !defined( $scanobj->{scan_name} ) );
	die "undefined scan_path."    if ( !defined( $scanobj->{scan_path} ) );
	die "undefined scan_options." if ( !defined( $scanobj->{scan_options} ) );
	die "Empty scan_path."        if ( $scanobj->{scan_path} eq "" );

	# TODO: validate scan_paths, etc.
	return;
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $bin_path     = $self->{agent}->{antivirus}->{scancli_path};
	my $scan_path    = $self->{job}->{obj}->{scan_path};
	my $scan_options = $self->{job}->{obj}->{scan_options};

	capture( $bin_path . " " . $scan_options . " " . $scan_path );

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Eset::Scan - Scan Task for ESET Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Antivirus on-demand scan and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

