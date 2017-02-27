use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);
use Try::Tiny;
use Armadito::Agent::Antivirus::Kaspersky::Task::Scan;

use lib 't/tests';
use Agent::Task::TestScan;

sub testScanOutput {

	my $output = '
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
';

	my $testscan = Agent::Task::TestScan->new();

	my $scan_class = Armadito::Agent::Antivirus::Kaspersky::Task::Scan->new(
		agent => $testscan->{agent},
		job   => $testscan->{job}
	);

	$scan_class->{start_time} = "1488207680";
	$scan_class->{end_time}   = "1488207683";
	$scan_class->{output}     = $output;
	$scan_class->_parseScanOutput();
}

plan tests => 1;

try {
	testScanOutput();
}
catch {
	fail("Kaspersky Scan test");
	print STDERR $_;
};

pass("Kaspersky Scan test");

1;
