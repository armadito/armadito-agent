package Armadito::Agent::Scheduler::Cron;

use strict;
use warnings;
use base 'Armadito::Agent::Task::Scheduler';

use Armadito::Agent::Config;
use Data::Dumper;

sub loadConf {
	my ( $self, %params ) = @_;

	$self->{config} = Armadito::Agent::Config->new();
	$self->{config}->loadDefaults( $self->_getDefaultConf() );
	$self->{config}->loadFromFile( $self->_getConfPath() );

}

sub _getDefaultConf {
	my ($self) = @_;

	return { 'user' => undef, };
}

sub _getConfPath {
	my ($self) = @_;

	return $self->{agent}->{confdir} . "/scheduler-" . lc( $self->{scheduler}->{name} ) . ".cfg";
}

sub updateScheduling {
	my ( $self, %params ) = @_;

}

sub run {
	my ( $self, %params ) = @_;

	$self = $self->SUPER::run(%params);
	$self->loadConf();

	return $self;
}

1;

__END__

=head1 NAME

Armadito::Agent::Scheduler::Cron - base class used for task scheduling management

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task::Scheduler>. It allows remote management of agent's crontab configuration.

=head1 FUNCTIONS

=head2 loadConf ( $self, %params )

Run the task.

=head2 updateScheduling ( $self, %params )

Run the task.
