package Armadito::Agent::Antivirus::Kaspersky::Task::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';
use Armadito::Agent::Patterns::Matcher;
use Armadito::Agent::Tools::Time qw(iso8601ToUnixTimestamp);

# 2016-11-30 16:04:36     C:\for_eric\75c1ae242d07bb738a5d9a9766c2a7de//data0000  detected        Exploit.JS.Pdfka.flm
# 2016-11-30 16:04:36     C:\for_eric\779cb6dc0055bdf63cbb2c9f9f3a95cc//data0000  suspicion       HEUR:Exploit.Script.Generic
# ;  --- Statistics ---
# ; Time Start:   2016-11-30 16:04:34
# ; Time Finish:  2016-11-30 16:04:37
# ; Processed objects:    131
# ; Total OK:     53
# ; Total detected:       57
# ; Suspicions:   21
# ; Total skipped:        0
# ; Password protected:   0
# ; Corrupted:    0
# ; Errors:       0
# ;  ------------------

sub _parseScanOutput {
	my ($self) = @_;

	my $parser = Armadito::Agent::Patterns::Matcher->new( logger => $self->{logger} );
	$parser->addPattern( 'scanned_count',    '^; Processed objects:\s+?(\d+)' );
	$parser->addPattern( 'malware_count',    '^; Total detected:\s+?(\d+)' );
	$parser->addPattern( 'suspicious_count', '^; Suspicions:\s+?(\d+)' );

	my $labels = [ 'detection_time', 'filepath', 'name' ];
	my $pattern = '^(\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(.*)\s+detected\s+([\w\.:]+)';
	$parser->addPattern( 'alerts', $pattern, $labels );

	$pattern = '^(\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(.*)\s+suspicion\s+([\w\.:]+)';
	$parser->addPattern( 'alerts', $pattern, $labels );

	$parser->run( $self->{output}, '\n' );

	$parser->addHookForLabel( 'filepath',       \&formatFilePath );
	$parser->addHookForLabel( 'detection_time', \&LocalToTimestamp );

	my $results = $parser->getResults();
	$self->{alerts} = $results->{alerts};
	$self->_setResults($results);
}

sub _setResults {
	my ( $self, $results ) = @_;

	delete( $results->{alerts} );
	$self->{results} = $results;
	$self->setResults();
}

sub formatFilePath {
	my ($match) = @_;

	$match =~ s/\/\/data(\d{4})/\\\\data$1/ms;

	return $match;
}

sub LocalToTimestamp {
	my ($match) = @_;

	return iso8601ToUnixTimestamp( $match, "Local" );
}

sub _setCmd {
	my ($self) = @_;

	my $bin_path     = $self->{agent}->{antivirus}->{scancli_path};
	my $scan_path    = $self->{job}->{obj}->{scan_path};
	my $scan_options = $self->{job}->{obj}->{scan_options};

	$self->{cmdline} = "\"" . $bin_path . "\" SCAN \"" . $scan_path . "\" " . $scan_options;
}

sub run {
	my ( $self, %params ) = @_;

	$self->SUPER::run(%params);

	$self->_setCmd();
	$self->execScanCmd();
	$self->_parseScanOutput();

	$self->sendScanResults();
	$self->sendScanAlerts();
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::Scan - Scan Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Antivirus on-demand scan and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

