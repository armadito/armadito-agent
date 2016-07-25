package Armadito::Agent::Task::Scan::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';

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

    # TODO: 
    # 1 : Send GET request to AV, asking for an on-demand scan
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
  "scan": "OK"
}';
	my $state_jobj =  from_json($av_response, { utf8  => 1 });

	$self->{jobj}->{task}->{msg} = $state_jobj;

	my $json_text = to_json($self->{jobj});

	print "JSON formatted str : \n".$json_text."\n";	

    my $response = $self->{client}->send(
		"url" => $self->{config}->{plugin_server_url}."/api/scans",
		message => $json_text,
		method => "POST"
    );

    if($response->is_success()){
         $self->_handleResponse($response);
         $self->{logger}->info("Scan successful...");
    }
    else{
         $self->_handleError($response);
         $self->{logger}->info("Scan failed...");
    }

    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Scan::Armadito - Scan Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Armadito Antivirus on-demand scan using AV's API REST protocol and then send a brief report in a json formatted POST request to Armadito plugin for GLPI. 

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

