package Armadito::Agent::HTTP::Client::ArmaditoAV::Event::OnDemandProgressEvent;

use strict;
use warnings;
use base 'Armadito::Agent::HTTP::Client::ArmaditoAV::Event';

use Armadito::Agent::Tools::Security qw(isANumber);

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{"progress"}         = $params{jobj}->{"progress"};
	$self->{"path"}             = $params{jobj}->{"path"};
	$self->{"malware_count"}    = $params{jobj}->{"malware_count"};
	$self->{"suspicious_count"} = $params{jobj}->{"suspicious_count"};
	$self->{"scanned_count"}    = $params{jobj}->{"scanned_count"};

	# TODO: Add more validation
	die "Invalid malware_count."    if !isANumber( $self->{"malware_count"} );
	die "Invalid suspicious_count." if !isANumber( $self->{"suspicious_count"} );
	die "Invalid scanned_count."    if !isANumber( $self->{"scanned_count"} );

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	return $self;
}
1;

__END__

=head1 NAME

Armadito::Agent::HTTP::Client::ArmaditoAV::Event::OnDemandProgressEvent - ArmaditoAV OnDemandProgressEvent class

=head1 DESCRIPTION

This is the class dedicated to OnDemandProgressEvent of ArmaditoAV api.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run event related stuff.

=head2 new ( $class, %params )

Instanciate this class.
