package Armadito::Agent::Antivirus::Eset::Alerts;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Alerts';

use Armadito::Agent::XML::Parser;
use Armadito::Agent::Tools::Dir qw(readDirectory);
use Armadito::Agent::Tools::File qw(readFile);
use English qw(-no_match_vars);
use Data::Dumper;
use JSON;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{maxalerts} = $self->{agent}->{config}->{"max-alerts"};
	$self->{glpi_url}  = $self->{agent}->{config}->{server}[0];

	return $self;
}

sub _handleError {

	my ( $self, $response ) = @_;

	$self = $self->SUPER::_handleError($response);

	return $self;
}

sub _processAlert {
	my ( $self, %params ) = @_;

	return 0;
}

sub _processAlertDir {
	my ($self) = @_;

	return $self;
}

sub _sendAlert {
	my ( $self, %params ) = @_;

	$self->{jobj}->{task}->{obj} = $params{xmlobj};

	my $json_text = to_json( $self->{jobj} );
	$self->{logger}->debug($json_text);

	my $response = $self->{glpi_client}->sendRequest(
		"url"   => $self->{glpi_url} . "/api/alerts",
		message => $json_text,
		method  => "POST"
	);

	if ( $response->is_success() ) {
		$self->{logger}->info("Alerts successful...");
	}
	else {
		$self->_handleError($response);
		$self->{logger}->info("Alerts failed...");
	}

	return 1;
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Eset::Alerts - Alerts Task for ESET Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Alerts>. Get Antivirus' alerts and send them as json messages to armadito glpi plugin.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

