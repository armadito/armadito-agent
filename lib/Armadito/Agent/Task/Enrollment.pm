package Armadito::Agent::Task::Enrollment;

use strict;
use warnings;
use base 'Armadito::Agent::Task';
use Data::Dumper;
use JSON;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	if ( $params{debug} ) {
		$self->{debug} = 1;
	}

	my $task = {
		name      => "Enrollment",
		antivirus => $self->{agent}->{antivirus}->getJobj()
	};

	$self->{jobj}->{task} = $task;

	return $self;
}

sub _handleResponse {
	my ( $self, $response ) = @_;

	$self->{logger}->info( $response->content() );

	my $jobj = from_json( $response->content(), { utf8 => 1 } );
	$self->_updateStorage($jobj);

	return $self;
}

sub _updateStorage {
	my ( $self, $jobj ) = @_;

	$self->{agent}->{agent_id}     = defined( $jobj->{agent_id} )     ? $jobj->{agent_id}     : 0;
	$self->{agent}->{scheduler_id} = defined( $jobj->{scheduler_id} ) ? $jobj->{scheduler_id} : 0;

	if ( $jobj->{agent_id} > 0 ) {
		$self->{agent}->_storeArmaditoIds();
		$self->{logger}->info( "Agent successfully enrolled with id " . $jobj->{agent_id} );
	}
}

sub _handleError {
	my ( $self, $response ) = @_;

	$self->{logger}->error( "Error Response : " . $response->content() . "\n" );
	if ( $response->content() =~ /^\s*\{/ ) {
		my $obj = from_json( $response->content(), { utf8 => 1 } );
		$self->{logger}->error( $obj->{message} );
	}
	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	$self->{jobj}->{task}->{obj} = '{}';
	my $json_text = to_json( $self->{jobj} );
	print $json_text. "\n";

	my $response = $self->{glpi_client}->sendRequest(
		"url"   => $self->{agent}->{config}->{server}[0] . "/api/agents",
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

Armadito::Agent::Task::Enrollment - Enrollment task of Armadito Agent.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task>. Enroll the device into Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



