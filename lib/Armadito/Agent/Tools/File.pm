package Armadito::Agent::Tools::File;

use strict;
use warnings;
use base 'Exporter';

use UNIVERSAL::require();
use Encode;
use English qw(-no_match_vars);
use Memoize;
use File::Which;
use Armadito::Agent::Tools qw (getNoWhere);

our @EXPORT_OK = qw(
	readFile
	writeFile
	getFileHandle
	canRun
	rmFile
);

if ( $OSNAME ne 'MSWin32' ) {
	memoize('canRun');
}

sub rmFile {
	my (%params) = @_;

	if ( -f $params{filepath} ) {
		unlink( $params{filepath} );
	}
}

sub readFile {
	my (%params) = @_;
	my $fh;

	if ( !open( $fh, "<", $params{filepath} ) ) {
		die "Error io $params{filepath} : $!";
	}

	return do { local $/; <$fh> };
}

sub writeFile {
	my (%params) = @_;
	my $fh;

	if ( !open( $fh, $params{mode}, $params{filepath} ) ) {
		die "Error io $params{filepath} : $!";
	}

	binmode $fh;
	print $fh $params{content};
	close $fh;
	return 1;
}

sub canRun {
	my ($binary) = @_;

	return $binary =~ m{^/} ? -x $binary :    # full path
		scalar( which($binary) );             # executable name
}

sub getFileHandle {
	my (%params) = @_;

	my $handle;

SWITCH: {
		if ( $params{file} ) {
			if ( !open $handle, '<', $params{file} ) {
				$params{logger}->error("Can't open file $params{file}: $ERRNO") if $params{logger};
				return;
			}
			last SWITCH;
		}
		if ( $params{command} ) {

			# FIXME: 'Bad file descriptor' error message on Windows
			$params{logger}->debug2("executing $params{command}")
				if $params{logger};

			# Turn off localised output for commands
			local $ENV{LC_ALL} = 'C';
			local $ENV{LANG}   = 'C';

			# Ignore 'Broken Pipe' warnings on Solaris
			local $SIG{PIPE} = 'IGNORE' if $OSNAME eq 'solaris';
			if ( !open $handle, '-|', $params{command} . " 2>" . getNoWhere() ) {
				$params{logger}->error("Can't run command $params{command}: $ERRNO") if $params{logger};
				return;
			}
			last SWITCH;
		}
		if ( $params{string} ) {
			open $handle, "<", \$params{string} or die;
			last SWITCH;
		}
		die "neither command, file or string parameter given";
	}

	return $handle;
}

1;
__END__

=head1 NAME

Armadito::Agent::Tools::File - Basic I/O functions used in Armadito Agent.

=head1 DESCRIPTION

This module provides some high level I/O functions for easy use.

=head1 FUNCTIONS

=head2 readFile(%params)

Read file and return its content in a scalar.

=over

=item I<filepath>

Path of the file to be read.

=back

=head2 writeFile(%params)

Write a scalar to a file in binary mode.

=over

=item I<content>

Content to write (scalar).

=item I<filepath>

Path of the file where content will be written to.

=item I<mode>

File opening mode.

=back

=head2 getFileHandle(%params)

Returns an open file handle on either a command output, a file, or a string.

=over

=item I<logger>

A logger object

=item I<command>

The command to use

=item I<file>

The file to use, as an alternative to the command

=item I<string>

The string to use, as an alternative to the command

=back

=head2 canRun($binary)

Returns true if given binary can be executed.

=head2 rmFile(%params)

Remove a file if it exists.

=over

=item I<filepath>

Path of the file to remove.

