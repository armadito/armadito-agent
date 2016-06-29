package Armadito::Agent::Task::PullRequest;

use strict;
use warnings;
use base 'Armadito::Agent::Task';

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

    if ($params{debug}) {
        $self->{debug} = 1;
    }

    return $self;
}

sub _encapsulate {

   my ( $self, $msg ) = @_;

   $self->{logger}->info("PullRequest Task Encapsulation...");

   # add Task info here
   $msg = '{ "taskname": "pullrequest", "msg": '.$msg."}"; 

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

    my $response = $self->{client}->send(
        "url" => $self->{config}->{plugin_server_url},
        args  => { 
            action    => "pullrequest",
            agentid => $self->{agentid}
        },
	method => "GET"
    );

    if($response->is_success()){
         $self->_handleResponse($response);
         $self->{logger}->info("PullRequest successful...");
    }
    else{
         $self->_handleError($response);
         $self->{logger}->info("PullRequest failed...");
    }
    
    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::PullRequest - PullRequest Task base class.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task>. Send a pull GET request to get jobs agent has to do according to Armadito Plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



