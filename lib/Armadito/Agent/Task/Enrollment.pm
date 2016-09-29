package Armadito::Agent::Task::Enrollment;

use strict;
use warnings;
use base 'Armadito::Agent::Task';

use Data::Dumper;
use JSON;

sub isEnabled {
	my ($self) = @_;

	return 1;
}

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

	$self->{jobj}->{task}        = $task;
	$self->{jobj}->{fingerprint} = $self->{agent}->{fingerprint};

	return $self;
}

sub _handleResponse {
	my ( $self, $response ) = @_;

	$self->{logger}->info( $response->content() );
	my $obj = from_json( $response->content(), { utf8 => 1 } );

	# Update armadito agent_id
	if ( defined( $obj->{agent_id} ) && $obj->{agent_id} > 0 ) {
		$self->{agent}->{agent_id} = $obj->{agent_id};
		$self->{agent}->_storeArmaditoId();
		$self->{logger}->info( "Agent successfully enrolled with id " . $obj->{agent_id} );
	}
	return $self;
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

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Enrollment - Enrollment task of Armadito Agent.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task>. Enroll the device into Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



