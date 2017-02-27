package Armadito::Agent::Antivirus::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Antivirus';
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);
use JSON;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{av_class}     = __PACKAGE__;
	$self->{name}         = "Armadito";
	$self->{program_path} = $self->getProgramPath();
	$self->{version}      = $self->getVersion();

	return $self;
}

sub getJobj {
	my ($self) = @_;

	return {
		name         => $self->{name},
		os_info      => $self->{os_info},
		version      => $self->{version},
		program_path => $self->{program_path}
	};
}

sub getVersion {
	my ($self) = @_;

	my $cmdline = "\"" . $self->{program_path} . "armadito-info\" --json";
	my $output  = capture( EXIT_ANY, $cmdline );
	my $jobj    = from_json( $output, { utf8 => 1 } );

	return $jobj->{antivirus_version};
}
1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito - Armadito Agent Antivirus base class.

=head1 DESCRIPTION

This is a base class for all stuff specific to an Antivirus.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate Armadito module. Set task's default logger.

=head2 getJobj ( $self )

Return unblessed object for json ecnapsulation.

=head2 getVersion ( $self )

Return Antivirus Version by using RESTful API /version.


