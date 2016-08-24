package Armadito::Agent::HTTP::Client::ArmaditoAV::Event::OnDemandCompletedEvent;

use strict;
use warnings;
use base 'Armadito::Agent::HTTP::Client::ArmaditoAV::Event';

use JSON;
use Armadito::Agent::Tools::Security qw(isANumber);

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	# TODO: Add more validation
	die "Invalid total_malware_count."    if !isANumber( $self->{jobj}->{"total_malware_count"} );
	die "Invalid total_suspicious_count." if !isANumber( $self->{jobj}->{"total_suspicious_count"} );
	die "Invalid total_scanned_count."    if !isANumber( $self->{jobj}->{"total_scanned_count"} );

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	$self->{taskobj}->{jobj}->{task}->{obj} = $self->{jobj};
	my $json_text = to_json( $self->{taskobj}->{jobj} );

	my $response = $self->{taskobj}->{glpi_client}->sendRequest(
		"url"   => $self->{taskobj}->{agent}->{config}->{armadito}->{server} . "/api/scans",
		message => $json_text,
		method  => "POST"
	);

	if ( $response->is_success() ) {
		$self->{taskobj}->_handleResponse($response);
		$self->{taskobj}->{logger}->info("Send Scan results successful...");
	}
	else {
		$self->{taskobj}->_handleError($response);
		$self->{taskobj}->{logger}->info("Send Scan results failed...");
	}

	$self->{end_polling} = 1;

	return $self;
}
1;

__END__

=head1 NAME

Armadito::Agent::HTTP::Client::ArmaditoAV::Event::OnDemandCompletedEvent - ArmaditoAV OnDemandCompletedEvent class

=head1 DESCRIPTION

This is the class dedicated to OnDemandCompletedEvent of ArmaditoAV api.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run event related stuff.

=head2 new ( $class, %params )

Instanciate this class.

