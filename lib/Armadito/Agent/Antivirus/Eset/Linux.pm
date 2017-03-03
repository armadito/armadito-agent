package Armadito::Agent::Antivirus::Eset::Linux;

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
			if ( $sl->{program} eq "esets_daemon" && $sl->{timestamp} >= $tssince );
	}

	return $selected_logs;
}

sub getProgramPath {
	my ($self) = @_;

	return "/opt/eset/esets/sbin/";
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Eset::Linux - Linux Specific code for ESETNod32 Antivirus

=head1 DESCRIPTION

This class regroup all Armadito AV stuff specific to linux.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module.

=head2 getSystemLogs ( $self )

Get Eset logs in Syslog.
