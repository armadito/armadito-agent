package Armadito::Agent::Task::Enrollment::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Enrollment';

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use Data::Dumper;
use JSON;

sub isEnabled {
	my ($self) = @_;

	return 1;
}

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	my $antivirus = {
		name    => "Armadito",
		version => ""
	};

	$self->{jobj}->{task}->{antivirus} = $antivirus;

	return $self;
}

sub _handleResponse {

	my ( $self, $response ) = @_;

	$self = $self->SUPER::_handleResponse($response);

	return $self;
}

sub _handleError {

	my ( $self, $response ) = @_;

	$self = $self->SUPER::_handleError($response);

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $enrollment_obj = '{}';    #TODO

	$self->{jobj}->{task}->{obj} = $enrollment_obj;

	my $json_text = to_json( $self->{jobj} );

	my $response = $self->{glpi_client}->sendRequest(
		"url"   => $self->{agent}->{config}->{armadito}->{server} . "/api/enrollment",
		message => $json_text,
		method  => "POST"
	);

	if ( $response->is_success() && $response->content() =~ /^\s*\{/ms ) {
		$self->_handleResponse($response);
		$self->{logger}->info("Enrollment successful...");
	}
	else {
		$self->_handleError($response);
		$self->{logger}->info("Enrollment failed...");
	}

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Enrollment::Armadito - Enrollment task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task::Enrollment>. Enroll the device in Armadito plugin for GLPI server.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



