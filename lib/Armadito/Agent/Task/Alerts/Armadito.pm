package Armadito::Agent::Task::Alerts::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Alerts';

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

	# TODO: get alerts

    my $av_response = '
{ "av_response":"alerts",
  "id":123,
  "status":0,
  "alert": "OK"
}';
	my $state_jobj =  from_json($av_response, { utf8  => 1 });

	$self->{jobj}->{task}->{msg} = $state_jobj;

	my $json_text = to_json($self->{jobj});

	print "JSON formatted str : \n".$json_text."\n";

    my $response = $self->{client}->send(
		"url" => $self->{config}->{plugin_server_url}."/api/alerts",
		message => $json_text,
		method => "POST"
    );

    if($response->is_success()){
         $self->_handleResponse($response);
         $self->{logger}->info("Alerts successful...");
    }
    else{
         $self->_handleError($response);
         $self->{logger}->info("Alerts failed...");
    }

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

