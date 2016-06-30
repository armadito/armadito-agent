package Armadito::Agent::Config;

use strict;
use warnings;

my $default = {
    'ca-cert-dir'             => undef,
    'ca-cert-file'            => undef,
    'color'                   => undef,
    'conf-reload-interval'    => 0,
    'debug'                   => undef,
    'force'                   => undef,
    'html'                    => undef,
    'local'                   => undef,
    'logger'                  => 'Stderr',
    'logfile'                 => undef,
    'logfacility'             => 'LOG_USER',
    'logfile-maxsize'         => undef,
    'no-ssl-check'            => undef,
    'proxy'                   => undef,
    'server'                  => undef,
    'stdout'                  => undef
};

my @supported_antiviruses = ("Armadito");
my @supported_tasks = ("State","Enrolment","PullRequest");

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

	$self->_loadDefaults();

	_isAntivirusSupported($params{options}->{antivirus}) or die "Unsupported Antivirus. Use --list-avs to see which antiviruses are supported.";
	_isTaskSupported($params{options}->{task}) or die "Unsupported Task. Use --list-tasks to see which tasks are supported.";

    return $self;
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub _isAntivirusSupported {
	my ($antivirus) = @_;
    foreach (@supported_antiviruses) {
	  if( $antivirus eq $_ ) {
		return 1;
	  }
	}
	return 0;
}

sub _isTaskSupported {
	my ($task) = @_;
    foreach (@supported_tasks) {
	  if( $task eq $_ ) {
		return 1;
	  }
	}
	return 0;
}

1;
__END__

=head1 NAME

Armadito::Agent::Config - Armadito Agent configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<options>

additional options override.

=back
