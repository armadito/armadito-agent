package Armadito::Agent::Antivirus::Armadito::Linux;

use strict;
use warnings;
use English qw(-no_match_vars);

sub new {
	my ( $class, %params ) = @_;

	my $self = { logger => $params{logger}, antivirus => $params{antivirus} };

	bless $self, $class;
	return $self;
}

sub getProgramPath {
	my ($self) = @_;

	my $path = "/usr/bin/";
	if ( -f $path . "armadito-scan" ) {
		return $path;
	}

	return "";
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito::Linux - Linux Specific code for Armadito Antivirus

=head1 DESCRIPTION

This class regroup all Armadito AV stuff specific to linux.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module.

=head2 getProgramPath ( $self )

Return the path where Armadito command line interface binaries are installed.
