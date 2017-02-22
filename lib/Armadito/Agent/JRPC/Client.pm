package Armadito::Agent::JRPC::Client;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;
use Data::Dumper;
use Armadito::Agent::Logger;
use Socket qw(PF_UNIX SOCK_SEQPACKET pack_sockaddr_un);
use JSON;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Agent::Logger->new(),
		sock => undef
	};

	bless $self, $class;

	socket( $self->{sock}, PF_UNIX, SOCK_SEQPACKET, 0 )
		or die "Unable to create socket: $!";

	my $sockaddr = pack_sockaddr_un( $params{sock_path} );

	connect( $self->{sock}, $sockaddr )
		or die "Unable to connect: $!";

	select $self->{sock};
	$| = 1;
	select STDOUT;

	return $self;
}

sub call {
	my ( $self, $jobj ) = @_;

	print { $self->{sock} } to_json($jobj);

	my $sock = $self->{sock};

	return from_json( <$sock>, { utf8 => 1 } );
}

1;
__END__

=head1 NAME

Armadito::Agent::JRPC::Client - A JRPC client

=head1 DESCRIPTION

This is the perl client implementation of a JSON-RPC protocol. 
It is used for the communication with Armadito Antivirus.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=head2 call($jobj)

Send given json object.
