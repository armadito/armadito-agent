package Armadito::Agent::Task;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use Armadito::Agent::HTTP::Client::Armadito;
use Data::Dumper;

sub isEnabled {
    my ($self) = @_;

    return 1;
}

sub run {
    my ( $self, %params ) = @_;

    $self->{logger}->info("Running Armadito module, plugin_server_url= ".$self->{config}->{plugin_server_url});
 
    $self->{client} = Armadito::Agent::HTTP::Client::Armadito->new();
    die "Error when creating client!" unless $self->{client};

    return $self;
}

sub new {
    my ( $class, %params ) = @_;

    my $self = { config => $params{config}};

	$self->{agent} = $params{agent};
	$self->{logger} = $self->{agent}->{logger};

	$self->{jobj} = {
		agent_id => $self->{agent}->{agent_id},
		agent_version => $FusionInventory::Agent::VERSION,
		task => ""
	};

	if(defined($self->{agent}->{fusionid})){
		$self->{logger}->info("Fusion Device Id : ".$self->{agent}->{fusionid});
	}

	$self->{logger}->info("Armadito agent Id : ".$self->{agent}->{agent_id});

    bless $self, $class;
    return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Task - Armadito Agent Task base class.

=head1 DESCRIPTION

This is a base class for each Tasks used to interact with Armadito Antivirus and Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Armadito module. Set task's default logger.

