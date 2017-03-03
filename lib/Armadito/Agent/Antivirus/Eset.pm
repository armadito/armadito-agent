package Armadito::Agent::Antivirus::Eset;

use strict;
use warnings;
use base 'Armadito::Agent::Antivirus';
use Try::Tiny;
use IPC::System::Simple qw(capture);

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{av_class}     = __PACKAGE__;
	$self->{name}         = "Eset";
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

	my $output = capture( $self->{program_path} . "esets_scan --version" );
	$self->{logger}->info($output);

	if ( $output =~ m/\)\s+([0-9\.]+)$/ms ) {
		return $1;
	}

	return "unknown";
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Eset - ESET Antivirus' class.

=head1 DESCRIPTION

This is a base class for all stuff specific to ESET Antivirus.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module. Set task's default logger.

=head2 getJobj ( $self )

Return unblessed object for json encapsulation.

=head2 getVersion ( $self )

Return Antivirus' Version.

=head2 getScanCliPath ( $self )

Return Antivirus' CLI binary scan path.


