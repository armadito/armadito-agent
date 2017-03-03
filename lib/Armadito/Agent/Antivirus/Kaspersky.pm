package Armadito::Agent::Antivirus::Kaspersky;

use strict;
use warnings;
use base 'Armadito::Agent::Antivirus';
use UNIVERSAL::require;
use English qw(-no_match_vars);

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{av_class}     = __PACKAGE__;
	$self->{name}         = "Kaspersky";
	$self->{program_path} = $self->getProgramPath();
	$self->{version}      = $self->getVersion();

	return $self;
}

sub getJobj {
	my ($self) = @_;

	return {
		name         => $self->{name},
		version      => $self->{version},
		os_info      => $self->{os_info},
		program_path => $self->{program_path}
	};
}

sub getVersion {
	my ($self) = @_;

	if ( $self->{program_path} =~ m/Kaspersky Anti-Virus (.*)$/ ) {
		return $1;
	}

	return "unknown";
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kapersky - Kaspersky Antivirus' class.

=head1 DESCRIPTION

This is a base class for all stuff specific to Kaspersky Antivirus.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module. Set task's default logger.

=head2 getJobj ( $self )

Return unblessed object for json encapsulation.

=head2 getVersion ( $self )

Return Antivirus' Version.


