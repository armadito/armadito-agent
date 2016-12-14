package Armadito::Agent::Antivirus::Kaspersky::Task::AVConfig;

use strict;
use warnings;
use base 'Armadito::Agent::Task::AVConfig';
use XML::LibXML;
use Data::Dumper;

sub run {
	my ( $self, %params ) = @_;
	
	$self = $self->SUPER::run(%params);
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
