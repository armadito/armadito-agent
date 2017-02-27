package Armadito::Agent::Task::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task';
use Armadito::Agent::Task::Alerts;
use MIME::Base64;
use Data::Dumper;
use JSON;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	if ( $params{debug} ) {
		$self->{debug} = 1;
	}

	my $task = {
		name      => "Scan",
		antivirus => $self->{agent}->{antivirus}->getJobj()
	};

	$self->{results}      = {};
	$self->{alerts}       = [];
	$self->{jobj}->{task} = $task;
	$self->{job}          = $params{job};
	$self->_validateScanObj( $self->{job}->{obj} );

	return $self;
}

sub _validateScanObj {
	my ( $self, $scanobj ) = @_;

	die "undefined scan_type."    if ( !defined( $scanobj->{scan_name} ) );
	die "undefined scan_path."    if ( !defined( $scanobj->{scan_path} ) );
	die "undefined scan_options." if ( !defined( $scanobj->{scan_options} ) );
	die "Empty scan_path."        if ( $scanobj->{scan_path} eq "" );

	if ( $scanobj->{scan_options} ne "" ) {
		$scanobj->{scan_options} = decode_base64( $scanobj->{scan_options} );
	}

	$scanobj->{scan_path} = decode_base64( $scanobj->{scan_path} );
}

sub sendScanResults {
	my ($self) = @_;

	$self->{jobj}->{task}->{obj} = $self->{results};
	my $json_text = to_json( $self->{jobj} );

	my $response = $self->{glpi_client}->sendRequest(
		"url"   => $self->{agent}->{config}->{server}[0] . "/api/scans",
		message => $json_text,
		method  => "POST"
	);

	if ( $response->is_success() ) {
		$self->{logger}->info("Send Scan results successful...");
	}
	else {
		$self->_handleError($response);
		$self->{logger}->info("Send Scan results failed...");
	}
}

sub sendScanAlerts {
	my ($self) = @_;

	my $alert_task = Armadito::Agent::Task::Alerts->new( agent => $self->{agent} );
	my $alert_jobj = {
		alerts => $self->{alerts},
		job_id => $self->{job}->{job_id}
	};

	$alert_task->run();
	$alert_task->_sendAlerts($alert_jobj);
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Scan - Scan Task base class

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task>. Launch a Antivirus on-demand scan and send a brief report to GPLI server Armadito plugin.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate Task.

=head2 run ( $self, %params )

Run the task.

=head2 sendScanAlerts ( $self )

Send to GLPI alerts stored in $self->{alerts}.

=head2 sendScanResults ( $self )

Send to GLPI Scan results stored in $self->{results}.

