package Armadito::Agent::Task::Enrollment;

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



