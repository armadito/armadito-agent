package Armadito::Agent::Antivirus::Kaspersky::Task::State;

use strict;
use warnings;
use base 'Armadito::Agent::Task::State';

use Armadito::Agent::Tools::File qw( readFile );
use Armadito::Agent::Patterns::Matcher;
use Armadito::Agent::Tools::Dir qw( readDirectory );
use File::stat;
use Data::Dumper;

# TODO : improve by parsing some bases index files
sub _getLastUpdateTime {
	my ($self) = @_;

	my $class = "Armadito::Agent::Antivirus::Kaspersky::Win32";
	$class->require();
	my $osclass  = $class->new( logger => $self->{logger} );
	my $basesdir = $osclass->getDatabasesPath();
	my @files    = readDirectory(
		dirpath => $basesdir,
		filter  => 'files-only'
	);

	@files = map { $basesdir . "\\" . $_ } @files;

	return $self->_getMostRecentTimestamp( \@files );
}

sub _getMostRecentTimestamp {
	my ( $self, $files ) = @_;

	my $max_timestamp = 0;
	foreach my $file (@$files) {
		my $timestamp = stat($file)->mtime;
		if ( $timestamp > $max_timestamp ) {
			$max_timestamp = $timestamp;
		}
	}

	return $max_timestamp;
}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);

	my $lastupdate = $self->_getLastUpdateTime();
	my $dbinfo = { global_update_timestamp => $lastupdate };

	$self->_sendToGLPI($dbinfo);
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::State - State Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:State>. Get Antivirus state and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.
