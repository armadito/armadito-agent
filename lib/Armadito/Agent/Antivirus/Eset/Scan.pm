package Armadito::Agent::Antivirus::Eset::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';

use Data::Dumper;
use Try::Tiny;
use IPC::System::Simple qw(capture);
use Armadito::Agent::Stdout::Parser;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);
	$self->_validateScanObj( $self->{job}->{obj} );

	return $self;
}

sub _validateScanObj {
	my ( $self, $scanobj ) = @_;

	die "undefined scan_type."    if ( !defined( $scanobj->{scan_name} ) );
	die "undefined scan_path."    if ( !defined( $scanobj->{scan_path} ) );
	die "undefined scan_options." if ( !defined( $scanobj->{scan_options} ) );
	die "Empty scan_path."        if ( $scanobj->{scan_path} eq "" );

	# TODO: validate scan_paths, etc.
	return;
}

# Scan completed at: mer. 23 nov. 2016 15:05:32 CET
# Scan time:         9 sec (0:00:09)
# Total:             files - 232, objects 1699
# Infected:          files - 188, objects 886
# Cleaned:           files - 0, objects 0

sub _parseScanOutput {
	my ( $self, $output ) = @_;

	my $parser = Armadito::Agent::Stdout::Parser->new( logger => $self->{logger} );
	$parser->addPattern( 'end_time',      '^Scan completed at: (.*)' );
	$parser->addPattern( 'duration',      '^Scan time:.+?\((.*?)\)' );
	$parser->addPattern( 'scanned_count', '^Total:\s+files - (\d+)' );
	$parser->addPattern( 'malware_count', '^Infected:\s+files - (\d+)' );
	$parser->addPattern( 'cleaned_count', '^Cleaned:\s+files - (\d+)' );

	if ( $output =~ m/(Scan completed at:.*)$/ms ) {
		$parser->run($1);
	}

	return $parser->getResults();
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $bin_path     = $self->{agent}->{antivirus}->{scancli_path};
	my $scan_path    = $self->{job}->{obj}->{scan_path};
	my $scan_options = $self->{job}->{obj}->{scan_options};

	my $output = capture( [ 0, 1, 10, 50 ], $bin_path . " " . $scan_options . " " . $scan_path );
	$self->{logger}->info($output);

	my $results = $self->_parseScanOutput($output);
	$results->{start_time}       = "";
	$results->{suspicious_count} = 0;
	$results->{progress}         = 100;
	$results->{job_id}           = $self->{job}->{job_id};

	$self->sendScanResults($results);
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Eset::Scan - Scan Task for ESET Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Antivirus on-demand scan and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

