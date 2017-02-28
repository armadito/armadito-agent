package Armadito::Agent::Antivirus::Armadito::Task::AVConfig;

use strict;
use warnings;
use base 'Armadito::Agent::Task::AVConfig';
use Armadito::Agent::Tools::File qw(readFile);
use Armadito::Agent::Patterns::Matcher;

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $conf_path = $self->_getOSConfPath() . "armadito.conf";
	my $conf = readFile( filepath => $conf_path );
	$self->_parseConf($conf);
	$self->_sendToGLPI();
}

sub _getOSConfPath {
	my ($self) = @_;

	my $osclass = $self->{agent}->{antivirus}->getOSClass();
	return $osclass->getConfPath();
}

sub _parseConf {
	my ( $self, $conf ) = @_;

	my @lines = split( "\n", $conf );

	my $current_block = "";
	foreach my $line (@lines) {
		if ( $line =~ /^\s*\[(.*?)\]\s*$/ms ) {
			$current_block = $1;
		}
		elsif ( $line =~ /^\s*([a-zA-Z0-9\-]+)\s*=\s*(.*)\s*$/ms ) {
			$self->_addConfEntry( $current_block . ":" . $1, $2 );
		}
	}
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito::Task::AVConfig - AVConfig Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:AVConfig>. Get Antivirus configuration and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.
