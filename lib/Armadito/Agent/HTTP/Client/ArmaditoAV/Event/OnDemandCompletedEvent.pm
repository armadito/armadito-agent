package Armadito::Agent::HTTP::Client::ArmaditoAV::Event::OnDemandCompletedEvent;

use strict;
use warnings;
use base 'Armadito::Agent::HTTP::Client::ArmaditoAV::Event';

use Armadito::Agent::Tools::Security qw(isANumber);

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{"start_time"}             = $params{jobj}->{"start_time"};
	$self->{"duration"}               = $params{jobj}->{"duration"};
	$self->{"total_malware_count"}    = $params{jobj}->{"total_malware_count"};
	$self->{"total_suspicious_count"} = $params{jobj}->{"total_suspicious_count"};
	$self->{"total_scanned_count"}    = $params{jobj}->{"total_scanned_count"};

	# TODO: Add more validation
	die "Invalid total_malware_count."    if !isANumber( $self->{"total_malware_count"} );
	die "Invalid total_suspicious_count." if !isANumber( $self->{"total_suspicious_count"} );
	die "Invalid total_scanned_count."    if !isANumber( $self->{"total_scanned_count"} );

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	# TODO : POST glpi/plugins/armadito api/scans
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

