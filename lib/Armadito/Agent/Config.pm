package FusionInventory::Agent::Config;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
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
