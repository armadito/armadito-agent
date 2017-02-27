use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);
use Try::Tiny;
use Armadito::Agent::Antivirus::Armadito::Task::Scan;

use lib 't/tests';
use Agent::Task::TestScan;

sub testScanOutput {

	my $output = '
{
    "timestamp": 1488207696,
    "type": "EVENT_DETECTION",
    "u": {
        "ev_detection": {
            "scan_action": "A6O_ACTION_NONE",
            "context": "CONTEXT_ON_DEMAND",
            "module_name": "clamav",
            "path": "/home/uhuru/malwares/PDFMalwaresSamples/for_eric/35d2cdb8a291740e091c4e77d79c09b7",
            "scan_status": "A6O_FILE_MALWARE",
            "module_report": "Pdf.Exploit.Dropped-94"
        }
    }
}

{
    "timestamp": 1488207696,
    "type": "EVENT_DETECTION",
    "u": {
        "ev_detection": {
            "scan_action": "A6O_ACTION_NONE",
            "context": "CONTEXT_ON_DEMAND",
            "module_name": "clamav",
            "path": "/home/uhuru/malwares/PDFMalwaresSamples/for_eric/3a1c724e5674aa03d813f8589f1e3e87",
            "scan_status": "A6O_FILE_MALWARE",
            "module_report": "Pdf.Exploit.Agent-36830"
        }
    }
}

{
    "timestamp": 1488207696,
    "type": "EVENT_ON_DEMAND_COMPLETED",
    "u": {
        "ev_on_demand_completed": {
            "total_malware_count": 24,
            "total_suspicious_count": 0,
            "total_scanned_count": 50
        }
    }
}
';

	my $testscan = Agent::Task::TestScan->new();

	my $scan_class = Armadito::Agent::Antivirus::Armadito::Task::Scan->new(
		agent => $testscan->{agent},
		job   => $testscan->{job}
	);

	$scan_class->_parseScanOutput($output);
}

plan tests => 1;

try {
	testScanOutput();
}
catch {
	fail("Armadito Scan test");
	print STDERR $_;
};

pass("Armadito Scan test");

1;
