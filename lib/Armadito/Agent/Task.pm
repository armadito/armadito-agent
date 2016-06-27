package FusionInventory::Agent::Task::Armadito;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::HTTP::Client::Armadito;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools::Hostname;
use Data::Dumper;

our $VERSION = "0.1.1";

sub isEnabled {
    my ($self) = @_;

    return 1;
}

sub _encapsulate {
   my ( $self, $msg ) = @_;

   $self->{logger}->info("Task Encapsulation...");

   my $header = '{ "agentVersion": "'.$FusionInventory::Agent::VERSION.'",
		   "deviceid": "'.$self->{agentid}.'",
                   "task":';
   my $footer = '}';

   $msg = $header.$msg.$footer;

   return $msg;
}

sub run {
    my ( $self, %params ) = @_;

    $self->{logger}->info("Running Armadito module, plugin_server_url= ".$self->{config}->{plugin_server_url});
 
    $self->{client} = FusionInventory::Agent::HTTP::Client::Armadito->new();
    die "Error when creating client!" unless $self->{client};

    return $self;
}

sub new {
    my ( $class, %params ) = @_;

    my $self = { config => $params{config}};

    $self->{logger} = FusionInventory::Agent::Logger->new(backends => ['Syslog', 'Stderr']);
    $self->{agentid} = 0;

    bless $self, $class;
    return $self;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::Armadito - FusionInventory module for Armadito AntiVirus.

=head1 DESCRIPTION

With this module, F<FusionInventory> can be used to manage Armadito AntiVirus.

This module uses SSL certificat to authentificate the server. You may have
to point F<--ca-cert-file> or F<--ca-cert-dir> to your public certificate.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Armadito module.

