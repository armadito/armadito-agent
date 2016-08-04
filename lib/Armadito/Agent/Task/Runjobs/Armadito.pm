package Armadito::Agent::Task::Runjobs::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Runjobs';

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use Data::Dumper;
use JSON;

sub isEnabled {
    my ($self) = @_;

    return 1;
}

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

	my $antivirus = {
		name => "Armadito",
		version => ""
	};

	$self->{jobj}->{task}->{antivirus} = $antivirus;

    return $self;
}

sub _getJobs {
	  my ($self, $job) = @_;
	  
}

sub _handleResponse {

    my ($self, $response) = @_;

    $self = $self->SUPER::_handleResponse($response);

    return $self;
}

sub _handleError {

    my ($self, $response) = @_;

	$self = $self->SUPER::_handleError($response);

    return $self;
}

sub run {
    my ( $self, %params ) = @_;

    $self = $self->SUPER::run(%params);
		

    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Runjobs::Armadito - Runjobs Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task::Runjobs>. Run Armadito jobs and send results to /jobs REST API of Armadito Plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



