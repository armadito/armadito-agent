package Armadito::Agent::Antivirus::Kaspersky::Task::Scan;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';

use Try::Tiny;
use MIME::Base64;
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);
use Armadito::Agent::Patterns::Matcher;
use Armadito::Agent::Task::Alerts;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	return $self;
}

sub _parseScanOutput {
	my ( $self, $output ) = @_;

	my $parser = Armadito::Agent::Patterns::Matcher->new( logger => $self->{logger} );
	return $parser->getResults();
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $bin_path     = $self->{agent}->{antivirus}->{scancli_path};
	my $scan_path    = $self->{job}->{obj}->{scan_path};
	my $scan_options = $self->{job}->{obj}->{scan_options};
	
	my $cmdline = "\"" . $bin_path . "\" SCAN \"" . $scan_path . "\" ". $scan_options;
		
	my $output = capture( EXIT_ANY, $cmdline );
	$self->{logger}->info($output);
	$self->{logger}->info("Program exited with ".$EXITVAL."\n");
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::Scan - Scan Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Antivirus on-demand scan and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

