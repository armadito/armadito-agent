package Armadito::Agent::Antivirus::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Antivirus';

sub isEnabled {
	my ($self) = @_;

	return 1;
}

sub getJobj {
	my ($self) = @_;

	return {
		name    => $self->{name},
		version => $self->{version}
	};
}

sub _getVersion {

	# TODO
	return "0.10.1";
}

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{name}    = "Armadito";
	$self->{version} = _getVersion();

	return $self;
}
1;

__END__

=head1 NAME

Armadito::Agent::Antivirus - Armadito Agent Antivirus base class.

=head1 DESCRIPTION

This is a base class for all stuff specific to an Antivirus.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 new ( $self, %params )

Instanciate Armadito module. Set task's default logger.

=head2 getJobj ( $self)

Return unblessed object for json ecnapsulation.


