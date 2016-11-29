package Armadito::Agent::Antivirus::Kaspersky::Win32;

use strict;
use warnings;
use English qw(-no_match_vars);
use Armadito::Agent::Tools::Dir qw( readDirectory );

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger},
	};

	bless $self, $class;
	return $self;
}

sub getProgramPath {
	my ($self) = @_;

	my @programfiles_paths = ( "C:\\Program Files (X86)\\",
							   "C:\\Program Files\\" );

	foreach my $path (@programfiles_paths) {
		if($self->_isProgramInDir($path)) {
			return $self->{program_path};
		}
	}

	return "";
}

sub _isProgramInDir {
	my ($self, $path) = @_;

	my @entries = readDirectory( dirpath => $path,
								 filter  => "dirs-only" );

	foreach my $entry (@entries) {
		$self->{logger}->info($entry);
	}

	return 0;
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Win32 - Win32 Specific code for Kaspersky Antivirus

=head1 DESCRIPTION

This class regroup all Kaspersky's Windows stuff.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module.

=head2 getProgramPath ( $self )

Return the path where Kapersky AV is installed.

