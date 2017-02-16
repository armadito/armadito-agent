use strict;
use warnings;

use Test::More;

use English qw(-no_match_vars);
use Try::Tiny;

use Armadito::Agent;
use Armadito::Agent::Antivirus;
use Armadito::Agent::Task::Enrollment;
use JSON;

sub initAgent {

	my $prefix = "";
	my %setup  = (
		confdir => $prefix . 'etc/',
		datadir => $prefix . 'share/',
		libdir  => $prefix . 'lib/',
		vardir  => $prefix . 'var/'
	);

	return Armadito::Agent->new(%setup);
}

sub doEnrollment {

	my $agent = initAgent();
	$agent->{config} = Armadito::Agent::Config->new();
	$agent->{config}->loadDefaults( $agent->_getDefaultConf() );
	$agent->{key}          = "AAAAF-111AF-DZ78F-EE78F-DDD1F";
	$agent->{agent_id}     = 0;
	$agent->{scheduler_id} = 0;

	$agent->{antivirus}                 = Armadito::Agent::Antivirus->new();
	$agent->{antivirus}->{name}         = "TestAV";
	$agent->{antivirus}->{version}      = "1.0.1";
	$agent->{antivirus}->{scancli_path} = "/usr/bin/avtest-scan-cli";

	my $task = Armadito::Agent::Task::Enrollment->new( agent => $agent );

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
