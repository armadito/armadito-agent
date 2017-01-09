package Armadito::Agent::Scheduler::Win32Native;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scheduler';

use Armadito::Agent::Tools::File qw (writeFile readFile);
use Armadito::Agent::Tools::Time qw (nowToISO8601);
use Armadito::Agent::Patterns::Matcher;
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);
use Data::Dumper;

sub _loadConf {
	my ( $self, %params ) = @_;

	$self->{config} = $self->_parseConf( $self->_getConfPath() );
}

sub _parseConf {
	my ( $self, $conf_path ) = @_;

	my $conf_file = readFile( filepath => $conf_path );

	my $parser = Armadito::Agent::Patterns::Matcher->new( logger => $self->{logger} );

	$parser->addPattern( 'logfile', 'Logfile\s*=\s*(.*)\s*$' );
	$parser->addPattern( 'user',    'User\s*=\s*(.*)\s*$' );

	my $labels = [ 'freq', 'name', 'args' ];
	my $pattern = '^([\s\*\d\/,]*?);(.*?);(.*?)$';
	$parser->addPattern( 'tasks', $pattern, $labels );

	$parser->run( $conf_file, '\n' );
	$parser->addHookForLabel( 'freq', \&trimSpaces );
	$parser->addHookForLabel( 'name', \&trimSpaces );
	$parser->addHookForLabel( 'args', \&trimSpaces );

	return $parser->getResults();
}

sub trimSpaces {
	my ($match) = @_;

	$match =~ s/\s+$//ms;
	$match =~ s/^\s+//ms;

	return $match;
}

sub _getDefaultConf {
	my ($self) = @_;

	return {
		'user'    => undef,
		'Logfile' => undef
	};
}

sub _getConfPath {
	my ($self) = @_;

	return $self->{agent}->{confdir} . "/scheduler-" . lc( $self->{scheduler}->{name} ) . ".cfg";
}

sub _createScheduledTask {
    my ($self) = @_;

	my $cmdline = "schtasks /Create";
    my $args    = "/SC MINUTE /TN ArmaditoAgentTaskEnrollment /RU SYSTEM ";
    $args      .= "/TR \"\\\"C:\\Program Files\\Armadito-Agent\\bin\\armadito-agent.bat\\\" -t 'Enrollment'\" /F";

	my $output  = capture( EXIT_ANY, $cmdline." ".$args );
	$self->{logger}->info($output);
	$self->{logger}->info("Program exited with " . $EXITVAL . "\n");
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);
	$self->_loadConf();
    $self->_createScheduledTask();

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Scheduler::Win32Native - class for managing native Win32 Scheduler.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task::Scheduler>. It allows remote management of agent's crontab configuration.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

