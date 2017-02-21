package Armadito::Agent::JRPC::Client;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use Armadito::Agent::Logger;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Agent::Logger->new(),
	};

	bless $self, $class;

	return $self;
}

sub request {
	my ( $self, $request, $file ) = @_;

	my $logger = $self->{logger};

	return $result;
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

=head2 request($request)

Send given jrpc request.
