package Armadito::Agent::Task::Scan::Armadito;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scan';

use Data::Dumper;
use JSON;
use Armadito::Agent::HTTP::Client::ArmaditoAV;

sub isEnabled {
    my ($self) = @_;
    return 1;
}

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

	my $antivirus = {
		name => "Armadito",
		version => ""
	};

	$self->{jobj}->{task}->{antivirus} = $antivirus;

    return $self;
}

sub _handleScanResponse {
    my ($self, $response) = @_;

    $self = $self->SUPER::_handleResponse($response);

    return $self;
}

sub _handleError {
    my ($self, $response) = @_;

	$self = $self->SUPER::_handleError($response);

    return $self;
}

sub _validateScanParams {
	my ( $self, %params ) = @_;

	die "undefined scan_type." if(!defined($params{obj}->{scan_name}));
	die "undefined scan_path." if(!defined($params{obj}->{scan_path}));
	die "Empty scan_path." if($params{obj}->{scan_path} eq "");

	# TODO: validate scan_paths, etc.
	return $self->setJsonScanMessage(%params);
}

sub setJsonScanMessage {
	my ( $self, %params ) = @_;

	$self->{json_message} = "{ 'path' : '".$params{obj}->{scan_path}."' }";
}

sub run {
    my ( $self, %params ) = @_;

    $self = $self->SUPER::run(%params);
	$self->_validateScanParams(%params);

	$self->{logger}->info("Armadito Scan launched.");
    $self->{av_client} = Armadito::Agent::HTTP::Client::ArmaditoAV->new();
    $self->{av_client}->register();

	my $response = $self->{av_client}->send(
		"url" => $self->{av_client}->{server_url}."/api/scan",
		message => $self->{json_message},
		method => "POST"
	);

	die "ArmaditoAV Scan request failed." if(!$response->is_success() || !$response->content() =~ /^\s*\{/ms);
	$self->_handleScanResponse($response);

    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task::Scan::Armadito - Scan Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:Scan>. Launch an Armadito Antivirus on-demand scan using AV's API REST protocol and then send a brief report in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

