package Armadito::Agent::Task;

use strict;
use warnings;

use Armadito::Agent;
use Armadito::Agent::Logger;
use Armadito::Agent::HTTP::Client::ArmaditoGLPI;
use Data::Dumper;

sub isEnabled {
	my ($self) = @_;

	return 1;
}

sub run {
	my ( $self, %params ) = @_;

	$self->{glpi_client} = Armadito::Agent::HTTP::Client::ArmaditoGLPI->new();
	die "Error when creating ArmaditoGLPI client!" unless $self->{glpi_client};

	return $self;
}

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Agent::Logger->new(),
		config => $params{config},
		agent  => $params{agent}
	};

	$self->{jobj} = {
		agent_id      => $self->{agent}->{agent_id},
		agent_version => $Armadito::Agent::VERSION,
		task          => ""
	};

	$self->{logger}->debug( "Armadito agent Id : " . $self->{agent}->{agent_id} );

	bless $self, $class;
	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task - Armadito Agent Task base class.

=head1 DESCRIPTION

This is a base class for each Tasks used to interact with Armadito Antivirus and Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Armadito module. Set task's default logger.

