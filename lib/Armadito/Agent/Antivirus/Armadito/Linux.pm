package Armadito::Agent::Antivirus::Armadito::Linux;

use strict;
use warnings;
use English qw(-no_match_vars);
use Parse::Syslog;

sub new {
	my ( $class, %params ) = @_;

	my $self = { logger => $params{logger}, antivirus => $params{antivirus} };

	bless $self, $class;
	return $self;
}

sub getSystemLogs {
	my ($self) = @_;

	my $selected_logs = "";
	my $tsnow         = time;
	my $tssince       = $tsnow - 3600;                           # last hour
	my $parser        = Parse::Syslog->new('/var/log/syslog');

	while ( my $sl = $parser->next ) {
		$selected_logs .= "timestamp=\"" . $sl->{timestamp} . "\", " . $sl->{text} . "\n"
			if ( $sl->{program} eq "armadito-journal" && $sl->{timestamp} >= $tssince );
	}

	return $selected_logs;
}

sub getProgramPath {
	my ($self) = @_;

	my $path = "/usr/bin/";
	if ( -f $path . "armadito-scan" ) {
		return $path;
	}

	return "";
}

sub getConfPath {
	my ($self) = @_;

	my $path = "/etc/armadito/";
	if ( -f $path . "armadito.conf" ) {
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

=head2 getConfPath ( $self )

Return the path where Armadito configuration files are.

=head2 getSystemLogs ( $self )

Get Armadito AV alert logs in Syslog.
