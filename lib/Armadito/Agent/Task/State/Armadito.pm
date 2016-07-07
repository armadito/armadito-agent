package Armadito::Agent::Task::State::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::State';

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

# 1 : Send GET request to AV, asking for AV state
# 2 : Handle AV response
# 3 : If successful, encapsulate AV state in a POST request to Armadito Plugin for GLPI 

    # TODO: 
    # 1 : Send GET request to AV, asking for AV state
    # my $req = $self->{client}->send(
    #    "url" => $self->{config}->{av_server_url},
    #    method => "GET"
    #    args  => { 
    #        action    => "getState"
    #    }
    #);

    my $av_response = '
{ "av_response":"state", 
  "id":123, 
  "status":0, 
  "info" : {
    "antivirus" : {
      "version": "3.14",
      "realtime": "on",
      "service": "on"
    },
    "agent": {
      "status": "on",
      "version": "1.0"
    },
    "update": {
      "status": "up-to-date",
      "last-update": "1970-01-01 00:00"
    },
    "modules": [
      {
        "name": "clamav",
        "version": "1.2",
        "update": {
          "status": "up-to-date",
          "last-update": "1970-01-01 00:00"
        }
      },
      {
        "name": "moduleH1",
        "version": "1.0",
        "update": {
          "status": "up-to-date",
          "last-update": "1970-01-01 00:00"
        }
      }
    ]
  }
}';


	$self->{jobj}->{task}->{msg} = $av_response;

	my $json_text = to_json($self->{jobj});

	print "JSON formatted str : \n".$json_text."\n";	

    my $response = $self->{client}->send(
		"url" => $self->{config}->{plugin_server_url}."/api/states",
		message => $json_text,
		method => "POST"
    );

    if($response->is_success()){
         $self->_handleResponse($response);
         $self->{logger}->info("State successful...");
    }
    else{
         $self->_handleError($response);
         $self->{logger}->info("State failed...");
    }

    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::State - State Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:State>. Ask for Armadito Antivirus state using AV's API REST protocol and then send it in a json formatted POST request to Armadito plugin for GLPI. 

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

