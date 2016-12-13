package Armadito::Agent::Tools::Time;

use strict;
use warnings;
use base 'Exporter';
use English qw(-no_match_vars);
use Time::Piece;
use Data::Dumper;

our @EXPORT_OK = qw(
	computeDuration
);

# ; Time Start:   2016-11-30 16:04:34
# ; Time Finish:  2016-11-30 16:04:37

sub computeDuration {
	my (%params) = @_;
	
	print "Start [".$params{start}."]\n";
	print "End [".$params{end}."]\n";
	my $format = '%Y-%m-%d %H:%M:%S';

	my $diff = Time::Piece->strptime($params{end}, $format)
         - Time::Piece->strptime($params{start}, $format);
	
	return _secondsToDuration($diff->seconds);
}

sub _secondsToDuration {
    my $totalsecs = shift;
	my ($hours, $mins, $secs, $leftover) = (0,0,0,0);

	$leftover = $totalsecs;
	if ($totalsecs >= 3600){
		$hours = $totalsecs/3600;
		$leftover = $totalsecs%3600;
	}

	if ($leftover >= 60){
		$mins = $leftover/60;
		$leftover = $leftover%60;
	}

	return "PT".$hours."H".$mins."M".$leftover."S";
}

1;
__END__

=head1 NAME

Armadito::Agent::Tools::Time - Tools for time manipulation

=head1 DESCRIPTION

This module provides some functions for time and date manipulation.

=head1 FUNCTIONS

=head2 computeDuration(%params)

Returns the duration at ISO8601 format.

=over

=item I<dirpath>

Path of the directory to read.
