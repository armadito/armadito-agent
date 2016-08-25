package Armadito::Agent::Antivirus;

use strict;
use warnings;

sub new {
	my ( $class, %params ) = @_;

	my $self = {};

	bless $self, $class;
	return $self;
}
1;

__END__

=head1 NAME

Armadito::Agent::Antivirus - Armadito Agent Antivirus base class.

=head1 DESCRIPTION

This is a base class for all stuff specific to an Antivirus.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate Armadito module.

