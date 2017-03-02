package Armadito::Agent::Antivirus::Eset::Task::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';
use Armadito::Agent::Patterns::Matcher;

#name="/home/malwares/contagio-malware/jar/MALWARE_JAR_200_files/Mal_Java_64FD14CEF0026D4240A4550E6A6F9E83.jar » ZIP » a/kors.class", threat="a variant of Java/Exploit.Agent.OKJ trojan", action="action selection postponed until scan completion", info=""

# Scan completed at: mer. 23 nov. 2016 15:05:32 CET
# Scan time:         9 sec (0:00:09)
# Total:             files - 232, objects 1699
# Infected:          files - 188, objects 886
# Cleaned:           files - 0, objects 0

sub _parseScanOutput {
	my ($self) = @_;

	my $parser = Armadito::Agent::Patterns::Matcher->new( logger => $self->{logger} );
	$parser->addPattern( 'scanned_count', '^Total:\s+files - (\d+)' );
	$parser->addPattern( 'malware_count', '^Infected:\s+files - (\d+)' );
	$parser->addPattern( 'cleaned_count', '^Cleaned:\s+files - (\d+)' );

	my $labels = [ 'filepath', 'name', 'action', 'info' ];
	my $pattern = '^name="(.*?)", threat="(.*?)", action="(.*?)", info="(.*?)"';
	$parser->addExclusionPattern(', threat="is OK",');
	$parser->addExclusionPattern(', threat="",');
	$parser->addExclusionPattern(', threat="multiple threats",');
	$parser->addPattern( 'alerts', $pattern, $labels );

	$parser->run( $self->{output}, '\n' );

	my $results = $parser->getResults();
	$self->{alerts} = $results->{alerts};
	$self->_setResults($results);
}

sub _setResults {
	my ( $self, $results ) = @_;

	delete( $results->{alerts} );
	$self->{results} = $results;
	$self->{results}->{suspicious_count} = 0;
	$self->setResults();
}

sub _setCmd {
	my ($self) = @_;

	my $bin_path     = $self->{agent}->{antivirus}->{scancli_path};
	my $scan_path    = $self->{job}->{obj}->{scan_path};
	my $scan_options = $self->{job}->{obj}->{scan_options};

	$self->{cmdline} = $bin_path . " " . $scan_options . " " . $scan_path;
}

sub run {
	my ( $self, %params ) = @_;

	$self->SUPER::run(%params);

	$self->_setCmd();
	$self->execScanCmd( exit_modes => [ 0, 1, 10, 50 ] );
	$self->_parseScanOutput();

	$self->sendScanResults();
	$self->sendScanAlerts();
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Eset::Task::Scan - Scan Task for ESET Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Antivirus on-demand scan and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

