package Armadito::Agent::Antivirus::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Antivirus';
use Armadito::Agent::HTTP::Client::ArmaditoAV;
use Armadito::Agent::JRPC::Client;
use English qw(-no_match_vars);
use Data::Dumper;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{name}    = "Armadito";
	$self->{version} = $self->getVersion();

	return $self;
}

sub getJobj {
	my ($self) = @_;

	return {
		name    => $self->{name},
		os_info => $self->{os_info},
		version => $self->{version}
	};
}

sub getVersion {
	my ($self) = @_;

	my $callobj = {
		jsonrpc => "2.0",
		method  => "status",
		id      => 1234
	};

	$self->{jrpc_client} = Armadito::Agent::JRPC::Client->new( sock_path => "\0/tmp/.armadito-daemon" );
	my $response = $self->{jrpc_client}->call($callobj);
	close( $self->{jrpc_client}->{sock} );

	return $response->{result}->{"antivirus-version"};
}
1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito - Armadito Agent Antivirus base class.

=head1 DESCRIPTION

This is a base class for all stuff specific to an Antivirus.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate Armadito module. Set task's default logger.

=head2 getJobj ( $self )

Return unblessed object for json ecnapsulation.

=head2 getVersion ( $self )

Return Antivirus Version by using RESTful API /version.

