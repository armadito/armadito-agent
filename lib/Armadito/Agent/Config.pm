package FusionInventory::Agent::Config;

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

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

	$self->_loadDefaults();

    return $self;
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
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
