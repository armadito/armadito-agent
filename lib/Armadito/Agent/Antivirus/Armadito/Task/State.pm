package Armadito::Agent::Antivirus::Armadito::Task::State;

use strict;
use warnings;
use base 'Armadito::Agent::Task::State';
use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);
use JSON;

sub run {
	my ( $self, %params ) = @_;

	$self->SUPER::run(%params);

	$self->{data} = {
		dbinfo    => {},
		avdetails => []
	};

	$self->getDbInfo();
	$self->_sendToGLPI( $self->{data} );

	return $self;
}

sub getDbInfo {
	my ($self) = @_;

	my $cmdline = "\"" . $self->{agent}->{antivirus}->{program_path} . "armadito-info\" --json";
	my $output  = capture( EXIT_ANY, $cmdline );
	my $jobj    = from_json( $output, { utf8 => 1 } );

	$self->{logger}->debug($output);

	$self->{data}->{dbinfo} = {
		global_status           => $jobj->{global_status},
		global_update_timestamp => $jobj->{global_update_ts},
		modules                 => []
	};

	foreach ( @{ $jobj->{module_infos} } ) {
		my $module_info = {
			name                 => $_->{name},
			mod_status           => $_->{mod_status},
			mod_update_timestamp => $_->{mod_update_ts}
		};

		push( @{ $self->{data}->{dbinfo}->{modules} }, $module_info );
	}
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Armadito::Task::State - State Task for Armadito Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:State>. Ask for Armadito Antivirus state using AV's API REST protocol and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task.

