package Armadito::Agent::Task::Runjobs;

use strict;
use warnings;
use base 'Armadito::Agent::Task';

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use Armadito::Agent::Storage;
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

	my $task = {
		name => "Runjobs",
		antivirus => ""
	};

	$self->{jobj}->{task} = $task;

    return $self;
}

sub _getJob {
	  my ($self, $job) = @_;
	    #$self->{agent}->{armadito_storage}->save(
		#	name => 'Armadito-Agent',
		#	data => $job
		#);
}

sub _getJobs {
	  my ($self, $job) = @_;

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

Armadito::Agent::Task::Runjobs - Runjobs Task base class.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task>. Run jobs and send results to /jobs REST API of Armadito Plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



