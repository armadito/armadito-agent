package FusionInventory::Agent::Task::Armadito::State;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::Armadito';

use FusionInventory::Agent::Config;
use FusionInventory::Agent::HTTP::Client::Armadito;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools::Hostname;
use Data::Dumper;
use JSON;

sub isEnabled {
    my ($self) = @_;

    return 1;
}

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    if ($params{debug}) {
        $self->{debug} = 1;
    }

    return $self;
}

sub _encapsulate {

   my ( $self, $msg ) = @_;

   $self->{logger}->info("State Task Encapsulation...");

   # add State Task info here
   $msg = '{ "taskname": "State", "msg": '.$msg."}"; 

   $msg = $self->SUPER::_encapsulate($msg);

   return $msg;
}

sub _handleResponse {

    my ($self, $response) = @_;

    # Parse response
    # print Dumper($response);
    print "Successful Response : ".$response->content()."\n";

    my $obj =  from_json($response->content(), { utf8  => 1 });

    print Dumper($obj);

    return $self;
}

sub _handleError {

    my ($self, $response) = @_;

    # Parse response
    # print Dumper($response);
    print "Error Response : ".$response->content()."\n";

    my $obj =  from_json($response->content(), { utf8  => 1 });

    print Dumper($obj);

    return $self;
}

sub run {
    my ( $self, %params ) = @_;

    $self = $self->SUPER::run(%params);

    print "Client :\n";
    print Dumper($self->{client})."\n";

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

    my $plugin_request = $self->_encapsulate($av_response);

    my $response = $self->{client}->send(
        "url" => $self->{config}->{plugin_server_url},
        message => $plugin_request,
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

FusionInventory::Agent::Task::Armadito::State - State task for Armadito AntiVirus.

=head1 DESCRIPTION

With this module, F<FusionInventory> can be used to manage Armadito AntiVirus.

This module uses SSL certificat to authentificate the server. You may have
to point F<--ca-cert-file> or F<--ca-cert-dir> to your public certificate.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

