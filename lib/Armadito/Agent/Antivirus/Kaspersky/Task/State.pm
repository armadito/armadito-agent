package Armadito::Agent::Antivirus::Kaspersky::Task::State;

use strict;
use warnings;
use base 'Armadito::Agent::Task::State';

use Data::Dumper;
use JSON;
use Armadito::Agent::Tools::File qw( readFile );
use Armadito::Agent::Patterns::Matcher;

sub _getDatabasesInfo {
	my ($self) = @_;
	return "";
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $dbinfo = $self->_getDatabasesInfo();
	$self->_sendToGLPI($dbinfo);
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::State - State Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:State>. Get Antivirus state and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

