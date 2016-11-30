package Armadito::Agent::Antivirus::Kaspersky::Win32;

use strict;
use warnings;
use English qw(-no_match_vars);
use Armadito::Agent::Tools::Dir qw( readDirectory );

sub new {
	my ( $class, %params ) = @_;

	my $self = { logger => $params{logger}, };

	bless $self, $class;
	return $self;
}

sub getProgramPath {
	my ($self) = @_;

	my $install_path = $self->getInstallPath();

	if ( $self->_isProgramInDir($install_path) ) {
		return $self->{program_path};
	}

	return "";
}

sub getInstallPath {
	my ($self) = @_;

	my @programfiles_paths = ( "C:\\Program Files (X86)", "C:\\Program Files" );
	foreach my $path (@programfiles_paths) {
		if( -d $path . "\\Kaspersky Lab") {
			return $path . "\\Kaspersky Lab";
		}
	}
}

sub _isProgramInDir {
	my ( $self, $path, $program ) = @_;

	my @entries = readDirectory(
		dirpath => $path,
		filter  => "dirs-only"
	);

	foreach my $entry (@entries) {
		if($entry =~ m/^Kaspersky Anti-Virus.*/){
			$self->{logger}->info($entry);
			$self->{program_path} = $path ."\\". $entry;
			return 1;
		}
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

Return the path where Kaspersky AV is installed.

