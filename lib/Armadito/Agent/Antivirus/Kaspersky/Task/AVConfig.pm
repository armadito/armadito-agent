package Armadito::Agent::Antivirus::Kaspersky::Task::AVConfig;

use strict;
use warnings;
use base 'Armadito::Agent::Task::AVConfig';
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);
use Armadito::Agent::Tools::File qw(rmFile);
use XML::LibXML;
use Data::Dumper;

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $export_path  = "C:\\Temp\\exported_settings.xml";
	rmFile( filepath => $export_path );

	if($self->_exportSettings($export_path) == 0){
		$self->_parseSettings($export_path);
	}
}

sub _exportSettings {
	my ( $self, $export_path ) = @_;

	my $bin_path     = $self->{agent}->{antivirus}->{scancli_path};

	my $cmdline = "\"" . $bin_path . "\" EXPORT \"" . $export_path . "\"";
	my $output = capture( EXIT_ANY, $cmdline );
	$self->{logger}->info($output);
	$self->{logger}->info( "Program exited with " . $EXITVAL . "\n" );

	return $EXITVAL;
}

sub _parseSettings {
	my ( $self, $export_path ) = @_;

	# TODO
}
1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::AVConfig - AVConfig Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:AVConfig>. Get Antivirus configuration and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.
