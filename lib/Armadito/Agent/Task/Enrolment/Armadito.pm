package Armadito::Agent::Task::Enrolment::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Enrolment';

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

    return $self;
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

    my $enrolment_msg = '{}';
    my $response = $self->{client}->send(
        "url" => $self->{config}->{plugin_server_url},
        args  => { 
            action    => "enrolment"
        },
	method => "GET"
    );

    if($response->is_success()){
         $self->_handleResponse($response);
         $self->{logger}->info("Enrolment successful...");
    }
    else{
         $self->_handleError($response);
         $self->{logger}->info("Enrolment failed...");
    }
   

    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Enrolment::Armadito - Enrolment task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task::Enrolment>. Enroll the device in Armadito plugin for GLPI server.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



