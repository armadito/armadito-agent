package Armadito::Agent::Task::Alerts::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Alerts';

use Armadito::Agent::XML::Parser;
use Armadito::Agent::Tools::Dir qw(readDirectory);
use Armadito::Agent::Tools::File qw(readFile);
use English qw(-no_match_vars);
use Data::Dumper;
use JSON;
use Carp;

sub isEnabled {
	my ($self) = @_;

	return 1;
}

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	print "alert-dir = " . $self->{agent}->{config}->{armadito}->{"alert-dir"} . "\n";

	if ( !-d $self->{agent}->{config}->{armadito}->{"alert-dir"} ) {
		croak("alert-dir not found or not a directory.");
	}

	$self->{alertdir}  = $self->{agent}->{config}->{armadito}->{"alert-dir"};
	$self->{maxalerts} = $self->{agent}->{config}->{armadito}->{"max-alerts"};
	$self->{glpi_url}  = $self->{agent}->{config}->{armadito}->{server}[0];

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

sub _processAlert {
	my ( $self, %params ) = @_;

	my $filecontent = readFile( filepath => $params{filepath} );
	my $parser = Armadito::Agent::XML::Parser->new( text => $filecontent );

	if ( !$parser->run() ) {
		return 1;
	}

	if ( !$self->_sendAlert( xmlobj => $parser->{xmlparsed} ) ) {
		return 1;
	}

	if ( !defined($self->{agent}->{config}->{armadito}->{"no-rm-alerts"}) ) {
		unlink $params{filepath};
	}

	return 0;
}

sub _processAlertDir {
	my ($self) = @_;
	my @alerts = readDirectory( dirpath => $self->{alertdir} );

	my $i      = 0;
	my $errors = 0;

	foreach my $alert (@alerts) {
		$errors += $self->_processAlert( filepath => $self->{alertdir} . "/" . $alert );
		$i++;
		last if ( $i - $errors >= $self->{maxalerts} && $self->{maxalerts} >= 0 );
	}

	print "$i alerts processed, $errors errors.\n";
	return $self;
}

sub _sendAlert {
	my ( $self, %params ) = @_;

	$self->{jobj}->{task}->{obj} = $params{xmlobj};

	my $json_text = to_json( $self->{jobj} );
	print "JSON formatted str : \n" . $json_text . "\n";

	my $response = $self->{glpi_client}->sendRequest(
		"url"   => $self->{glpi_url} . "/api/alerts",
		message => $json_text,
		method  => "POST"
	);

	if ( $response->is_success() ) {
		$self->_handleResponse($response);
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

	$self->_processAlertDir();

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Alerts::Armadito - Alerts Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Get Armadito Antivirus alerts and send them as json messages to armadito glpi plugin.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

