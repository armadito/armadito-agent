package Agent::Task::TestScan;

use strict;
use warnings;

use lib 't/tests';
use TestAgent;

sub new {
	my ( $class, %params ) = @_;

	my $testagent = TestAgent->new();
	$testagent->init();

	my $job = {
		job_priority => '2',
		obj          => {
			'scan_path'     => 'L2hvbWUvdWh1cnUvbWFsd2FyZXMvUERGTWFsd2FyZXNTYW1wbGVzLw==',
			'scan_name'     => 'scan_2',
			'scan_options'  => 'LXI=',
			'scanconfig_id' => 2
		},
		job_id   => 50,
		job_type => 'Scan'
	};

	my $self = {
		agent => $testagent->{agent},
		job   => $job
	};

	bless $self, $class;
	return $self;
}
1;
