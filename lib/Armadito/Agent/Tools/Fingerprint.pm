package Armadito::Agent::Tools::Fingerprint;

use strict;
use warnings;
use base 'Exporter';

use UNIVERSAL::require();
use Encode;
use English qw(-no_match_vars);

use Armadito::Agent::Tools::File qw(canRun);
use Armadito::Agent::Tools::Dmidecode qw(getDmidecodeInfos);

our @EXPORT_OK = qw(
	getFingerprint
);

sub getFingerprint {
	my (%params) = @_;

	my $fingerprint
		= $OSNAME eq 'MSWin32'
		? _getFingerprintWindows()
		: _getFingerprintUnix();

	print $fingerprint. "\n";
	return $fingerprint;
}

sub _getFingerprintUnix {
	my $fingerprint;

	if ( canRun('dmidecode') ) {
		$fingerprint = _getSystemInfos();
	}

	return $fingerprint;
}

sub _getFingerprintWindows {
	my $fingerprint;

	if ( canRun('dmidecode') ) {
		$fingerprint = _getSystemInfos();
	}

	return $fingerprint;
}

sub _getSystemInfos {
	my $infos       = getDmidecodeInfos();
	my $bios_info   = $infos->{0}->[0];
	my $system_info = $infos->{1}->[0];

	$infos = "";
	$infos .= $system_info->{'UUID'} if ( defined( $system_info->{'UUID'} ) );
	$infos .= "---" . $system_info->{'Serial Number'} if ( defined( $system_info->{'Serial Number'} ) );

	return $infos;
}

1;
__END__

=head1 NAME

Armadito::Agent::Tools::Fingerprint - OS-independent fingerprint computing

=head1 DESCRIPTION

This module provides a generic function to retrieve a fingerprint for this computer.

=head1 FUNCTIONS

=head2 getFingerprint()

Returns a fingerprint for this computer.
