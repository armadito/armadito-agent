package Armadito::Agent::Task::Runjobs;

use strict;
use warnings;
use base 'Armadito::Agent::Task';

use Armadito::Agent::Storage;
use Data::Dumper;
use JSON;

sub isEnabled {
	my ($self) = @_;

	return 1;
}

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	if ( $params{debug} ) {
		$self->{debug} = 1;
	}

	my $task = {
		name      => "Runjobs",
		antivirus => $self->{agent}->{antivirus}->getJobj()
	};

	$self->{jobj}->{task} = $task;

	return $self;
}

sub _getStoredJobs {
	my ($self) = @_;

	my $data = $self->{agent}->{armadito_storage}->restore( name => 'Armadito-Agent-Jobs' );
	if ( defined( $data->{jobs} ) ) {
		foreach my $job ( @{ $data->{jobs} } ) {
			$self->{logger}->info( "Job " . $job->{job_id} . " - " . $job->{job_priority} );
		}
		$self->{jobs} = $data->{jobs};
	}

	return $self;
}

sub _rmJobFromStorage {
	my ( $self, $job_id ) = @_;

	my $jobs = ();
	my $data = $self->{agent}->{armadito_storage}->restore( name => 'Armadito-Agent-Jobs' );
	if ( defined( $data->{jobs} ) ) {
		foreach ( @{ $data->{jobs} } ) {
			push( @$jobs, $_ ) if $_->{job_id} ne $job_id;
		}
	}

	$self->{agent}->{armadito_storage}->save(
		name => 'Armadito-Agent-Jobs',
		data => {
			jobs => $jobs
		}
	);
}

sub _sortJobsByPriority {
	my ($self) = @_;

	@{ $self->{jobs} } = sort { $a->{job_priority} <=> $b->{job_priority} } @{ $self->{jobs} };

	return $self;
}

sub _handleResponse {
	my ( $self, $response ) = @_;

	$self->{logger}->info( "Successful Response : " . $response->content() );
	my $obj = from_json( $response->content(), { utf8 => 1 } );
	$self->{logger}->info( Dumper($obj) );

	return $self;
}

sub _handleError {
	my ( $self, $response ) = @_;

	$self->{logger}->info( "Error Response : " . $response->content() );
	my $obj = from_json( $response->content(), { utf8 => 1 } );
	$self->{logger}->error( Dumper($obj) );

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);
	$self = $self->_getStoredJobs();
	$self = $self->_sortJobsByPriority();

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



