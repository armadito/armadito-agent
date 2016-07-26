package Armadito::Agent::Tools::Fingerprint;

use strict;
use warnings;
use base 'Exporter';

use UNIVERSAL::require();
use Encode;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Hostname;

our @EXPORT = qw(
    getFingerprint
);

sub getFingerprint {
    my (%params) = @_;

    my $fingerprint = $OSNAME eq 'MSWin32' ?
        _getFingerprintWindows() :
        _getFingerprintUnix()    ;

    return $fingerprint;
}

sub _getFingerprintUnix {
	my $fingerprint = "";
	my $hostname = getHostname();

    return $fingerprint.$hostname;
}

sub _getFingerprintWindows {
	my $fingerprint = "";
	my $hostname = getHostname();

    return $fingerprint.$hostname;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Fingerprint - OS-independent fingerprint computing

=head1 DESCRIPTION

This module provides a generic function to retrieve a fingerprint for this computer. It is basically based on hostname.

=head1 FUNCTIONS

=head2 getFingerprint()

Returns a fingerprint for this computer.
