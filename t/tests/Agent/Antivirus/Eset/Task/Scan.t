use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);
use Try::Tiny;
use Armadito::Agent::Antivirus::Eset::Task::Scan;

use lib 't/tests';
use Agent::Task::TestScan;

sub testScanOutput {

	my $output = '
name="/home/malwares/contagio-malware/jar/MALWARE_JAR_200_files/10.jar » ZIP » a/kors.class", threat="Java/Exploit.Agent.OKJ", action="action selection postponed until scan completion", info=""

name="/home/malwares/contagio-malware/jar/MALWARE_JAR_200_files/Mal_Java_64FD14CEF0026D4240A4550E6A6F9E83.jar » ZIP » a/kors.class", threat="a variant of Java/Exploit.Agent.OKJ trojan", action="action selection postponed until scan completion", info=""

Scan completed at: mer. 23 nov. 2016 15:05:32 CET
Scan time:         9 sec (0:00:09)
Total:             files - 232, objects 1699
Infected:          files - 188, objects 886
Cleaned:           files - 0, objects 0
';

	my $testscan = Agent::Task::TestScan->new();

	my $scan_class = Armadito::Agent::Antivirus::Eset::Task::Scan->new(
		agent => $testscan->{agent},
		job   => $testscan->{job}
	);

	$scan_class->{start_time} = "1488207680";
	$scan_class->{end_time}   = "1488207689";
	$scan_class->{output}     = $output;
	$scan_class->_parseScanOutput($output);
}

plan tests => 1;

try {
	testScanOutput();
}
catch {
	fail("Eset Scan test");
	print STDERR $_;
};

pass("Eset Scan test");

1;
