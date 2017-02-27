use strict;
use warnings;

use Test::More;

use English qw(-no_match_vars);
use Try::Tiny;
use Armadito::Agent::Task::Enrollment;
use JSON;

use lib 't/tests';
use TestAgent;

sub doEnrollment {

	my $testagent = TestAgent->new();
	$testagent->init();

	my $task = Armadito::Agent::Task::Enrollment->new( agent => $testagent->{agent} );

	is( $task->{jobj}->{agent_id},                     0,       "TaskObjAgent" );
	is( $task->{jobj}->{task}->{antivirus}->{version}, "1.0.1", "TaskAV" );

	$task->_setEnrollmentKey();
	my $json_text = to_json( $task->{jobj} );
}

plan tests => 3;

try {
	doEnrollment();
}
catch {
	fail("Enrollment task");
	print STDERR $_;
};

pass("Enrollment  task");

1;
