package Armadito::Agent::Task::Runjobs;

use strict;
use warnings;
use base 'Armadito::Agent::Task';

use Armadito::Agent::Storage;
use Data::Dumper;
use MIME::Base64;
use Try::Tiny;
use JSON;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	my $task = {
		name      => "Runjobs",
		antivirus => $self->{agent}->{antivirus}->getJobj()
	};

	$self->{jobj}->{task} = $task;
	$self->{jobs} = [];

	return $self;
}

sub _getStoredJobs {
	my ($self) = @_;

	my $data = $self->{agent}->{armadito_storage}->restore( name => 'Armadito-Agent-Jobs' );
	if ( defined( $data->{jobs} ) ) {
		$self->{jobs} = $data->{jobs};
	}
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

	@{ $self->{jobs} } = reverse sort { $a->{job_priority} <=> $b->{job_priority} } @{ $self->{jobs} };
}

sub run {
	my ( $self, %params ) = @_;

	$self->SUPER::run(%params);
	$self->_getStoredJobs();

	if ( scalar @{ $self->{jobs} } > 0 ) {
		$self->_sortJobsByPriority();
		$self->_runJobs();
	}
}

sub _runJob {
	my ( $self, $job ) = @_;
	my $config     = ();
	my $start_time = time;
	my $error      = "";

	try {
		my $antivirus = $self->{jobj}->{task}->{antivirus}->{name};
		my $task      = $job->{job_type};
		my $class     = "Armadito::Agent::Task::$task";

		if ( $self->{agent}->isTaskSpecificToAV($task) ) {
			$class = "Armadito::Agent::Antivirus::" . $antivirus . "::Task::" . $task;
		}

		$class->require();
		my $taskclass = $class->new( agent => $self->{agent}, job => $job );
		$taskclass->run();
	}
	catch {
		$error = $_ if defined($_);
	};

	$self->_setJobStatusResponse( $job, $error, $start_time );
}

sub _setJobStatusResponse {
	my ( $self, $job, $error, $start_time ) = @_;

	my $code    = 0;
	my $message = "runJob successful";

	if ( $error ne "" ) {
		$code    = 1;
		$message = encode_base64($error);
		$self->{logger}->error($error);
	}

	$self->{jobj}->{task}->{obj} = {
		code       => $code,
		message    => $message,
		job_id     => $job->{job_id},
		start_time => $start_time,
		end_time   => time
	};
}

sub _runJobs {
	my ($self) = @_;

	foreach my $job ( @{ $self->{jobs} } ) {
		$self->{logger}->debug( "Run job " . $job->{job_id} );
		$self->_runJob($job);
		$self->_sendStatus();
		$self->_rmJobFromStorage( $job->{job_id} );
	}
}

sub _sendStatus {
	my ($self) = @_;

	my $json_text = to_json( $self->{jobj} );

	$self->{logger}->debug2($json_text);

	my $response = $self->{glpi_client}->sendRequest(
		url     => $self->{agent}->{config}->{server}[0] . "/api/jobs",
		message => $json_text,
		method  => "POST"
	);

	if ( $response->is_success() ) {
		$self->{logger}->info("Runjobs sendStatus successful...");
	}
	else {
		$self->_handleError($response);
		$self->{logger}->info("Runjobs sendStatus failed...");
	}
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Runjobs - Runjobs Task base class.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task>. Run jobs and send results to /jobs REST API of Armadito Plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.



