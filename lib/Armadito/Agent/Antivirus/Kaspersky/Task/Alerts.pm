package Armadito::Agent::Antivirus::Kaspersky::Task::Alerts;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Alerts';

use Armadito::Agent::Patterns::Matcher;
use Armadito::Agent::XML::Parser;
use Armadito::Agent::Tools::Dir qw(readDirectory);
use Armadito::Agent::Tools::File qw(readFile);
use English qw(-no_match_vars);
use JSON;
use Parse::Syslog;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	return $self;
}


sub run {
	my ( $self, %params ) = @_;
	
	$self = $self->SUPER::run(%params);

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::Alerts - Alerts Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Alerts>. Get Antivirus' alerts and send them as json messages to armadito glpi plugin.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

