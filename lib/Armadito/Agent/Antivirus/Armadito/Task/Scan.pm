package Armadito::Agent::Antivirus::Armadito::Task::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $bin_path     = $self->{agent}->{antivirus}->{program_path} . "armadito-scan";
	my $scan_path    = $self->{job}->{obj}->{scan_path};
	my $scan_options = $self->{job}->{obj}->{scan_options};

	my $cmdline = "\"" . $bin_path . "\" --json " . $scan_options . " \"" . $scan_path . "\"";
	my $output = capture( EXIT_ANY, $cmdline );
	$self->{logger}->info($output);
	$self->{logger}->info( "Program exited with " . $EXITVAL . "\n" );

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito::Task::Scan - Scan Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Armadito Antivirus on-demand scan using AV's API REST protocol and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

