package FusionInventory::Agent::Task::Armadito::Enrolment;

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

    my $enrolment_msg = '{}';
    my $response = $self->{client}->send(
        "url" => $self->{config}->{plugin_server_url},
        args  => { 
            action    => "enrolment"
        },
	method => "GET"
    );

    if($response->is_success()){
         $self->_handleResponse($response);
         $self->{logger}->info("Enrolment successful...");
    }
    else{
         $self->_handleError($response);
         $self->{logger}->info("Enrolment failed...");
    }
   

    return $self;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::Armadito::Enrolment - Enrolment task for Armadito AntiVirus.

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



