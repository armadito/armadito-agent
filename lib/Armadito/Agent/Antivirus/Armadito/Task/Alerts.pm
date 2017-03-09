package Armadito::Agent::Antivirus::Armadito::Task::Alerts;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Alerts';
use Armadito::Agent::Patterns::Matcher;
use Data::Dumper;

# Mar  9 14:48:45 uhuru-ThinkPad-L540 armadito-journal[30027]: type="detection", context="real-time", scan_id=0, path="/home/uhuru/malwares/contagio-malware/elf-linux/MALWARE_ELF_LINUX_100_files/ELF_FC805DBA06638E410EBFF1E18FAF23D9", scan_status="malware", scan_action="none", module_name="clamav", module_report="Unix.Malware.Agent-1577465"
# Mar  9 14:48:45 uhuru-ThinkPad-L540 armadito-journal[30027]: type="detection", context="real-time", scan_id=0, path="/home/uhuru/malwares/contagio-malware/elf-linux/MALWARE_ELF_LINUX_100_files/ELF_Linux_SSHDoor_90DC9DE5F93B8CC2D70A1BE37ACEA23A", scan_status="malware", scan_action="none", module_name="clamav", module_report="Unix.Trojan.SSHDoor-1"

sub _parseLogs {
	my ( $self, $logs ) = @_;

	my $parser = Armadito::Agent::Patterns::Matcher->new( logger => $self->{logger} );

	my $labels = [ 'detection_time', 'info', 'filepath', 'action', 'module_name', 'name' ];
	my $pattern = 'timestamp="(.*?)".*?type="detection", context="(.*?)", scan_id=.*?, path="(.*?)", ';
	$pattern .= 'scan_status=".*?", scan_action="(.*?)", module_name="(.*?)", module_report="(.*?)"';

	$parser->addPattern( "alerts", $pattern, $labels );
	$parser->run( $logs, '\n' );

	return $parser->getResults();
}

sub run {
	my ( $self, %params ) = @_;

	$self->SUPER::run(%params);

	my $osclass      = $self->{agent}->{antivirus}->getOSClass();
	my $journal_logs = $osclass->getSystemLogs();

	if ( $journal_logs eq "" ) {
		$self->{logger}->info("No alerts found.");
		return;
	}

	my $alerts   = $self->_parseLogs($journal_logs);
	my $n_alerts = @{ $alerts->{alerts} };
	$self->{logger}->info( $n_alerts . " alert(s) found." );
	$self->_sendAlerts($alerts);
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito::Task::Alerts - Alerts Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Alerts>. Get Armadito Antivirus alerts and send them as json messages to armadito glpi plugin.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

