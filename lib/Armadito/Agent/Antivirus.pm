package Armadito::Agent::Antivirus;

use strict;
use warnings;
use English qw(-no_match_vars);

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger  => $params{logger},
		os_info => ""
	};

	bless $self, $class;

	$self->{os_info} = $self->getOperatingSystemInfo();

	return $self;
}

sub getOperatingSystemInfo {
	my ($self) = @_;

	my $os_info = {
		name    => $OSNAME,
		libpath => $OSNAME
	};

	if ( $OSNAME eq "MSWin32" ) {
		$os_info->{libpath} = "Win32";
	}
	else {
		$os_info->{libpath} = "Linux";
	}

	return $os_info;
}

sub getOSClass {
	my ($self) = @_;

	my $class = $self->{av_class} . "::" . $self->{os_info}->{libpath};
	$class->require();
	my $osclass = $class->new( logger => $self->{logger}, antivirus => $self );

	return $osclass;
}

sub getProgramPath {
	my ($self) = @_;

	my $osclass = $self->getOSClass();
	return $osclass->getProgramPath();
}

sub getDataPath {
	my ($self) = @_;

	my $osclass = $self->getOSClass();
	return $osclass->getDataPath();
}

sub getJobj {
	my ($self) = @_;

	return {
		name         => $self->{name},
		version      => $self->{version},
		os_info      => $self->{os_info},
		scancli_path => $self->{scancli_path}
	};
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

=head2 getOperatingSystemInfo ( $self )

Get Operating system information.

=head2 getJobj ( $self )

Return unblessed object for json encapsulation.

=head2 getProgramPath ( $self )

Return Antivirus' Program path. i.e. bin directory.

=head2 getDataPath ( $self )

Return Antivirus' data path.
