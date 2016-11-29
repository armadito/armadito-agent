package Armadito::Agent::Antivirus::Kaspersky;

use strict;
use warnings;
use base 'Armadito::Agent::Antivirus';

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{name}         = "Kaspersky";
	$self->{scancli_path} = $self->getProgramPath()."\avp.com";
	$self->{version}      = $self->getVersion();

	return $self;
}

sub getJobj {
	my ($self) = @_;

	return {
		name         => $self->{name},
		version      => $self->{version},
		scancli_path => $self->{scancli_path}
	};
}

sub getVersion {
	my ($self) = @_;

	return "17.0.0";
}

sub getProgramPath {
	my ($self) = @_;

	return 'C:\Program Files (x86)\Kaspersky Lab\Kaspersky Anti-Virus 17.0.0';
}

1;

__END__

=head1 NAME

Armadito::Agent::Kapersky - Kaspersky Antivirus' class.

=head1 DESCRIPTION

This is a base class for all stuff specific to Kaspersky Antivirus.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module. Set task's default logger.

=head2 getJobj ( $self )

Return unblessed object for json encapsulation.

=head2 getVersion ( $self )

Return Antivirus' Version.

=head2 getScanCliPath ( $self )

Return Antivirus' CLI binary scan path.


