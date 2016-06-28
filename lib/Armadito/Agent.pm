package Armadito::Agent;

use 5.008000;
use strict;
use warnings;

require Exporter;

use Armadito::Agent::Config;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = "0.0.3_01";

sub new {
    my ($class, %params) = @_;

    my $self = {
        status  => 'unknown',
        confdir => $params{confdir},
        datadir => $params{datadir},
        libdir  => $params{libdir},
        vardir  => $params{vardir},
        sigterm => $params{sigterm},
        targets => [],
        tasks   => []
    };
    bless $self, $class;

    return $self;
}

sub init {
    my ($self, %params) = @_;

    $self->{config} = Armadito::Agent::Config->new(
        confdir => $self->{confdir},
        options => $params{options},
    );
}

1;
__END__
=head1 NAME

Armadito::Agent - Armadito Agent

=head1 VERSION

0.0.3_01

=head1 DESCRIPTION

Agent interfacing between Armadito Antivirus and Armadito plugin for GLPI for Windows and Linux.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<datadir>

the read-only data directory.

=item I<vardir>

the read-write data directory.

=item I<options>

the options to use.

=back

=head2 init()

Initialize the agent.

=head1 SEE ALSO

=over 4

=item * L<http://armadito-av.readthedocs.io/en/latest/>

Armadito online documentation.

=item * L<https://github.com/armadito>

Armadito organization on github.

=item * L<http://www.glpi-project.org/>

GLPI Project main page.

=back

=cut

=head1 AUTHOR

vhamon, E<lt>vhamon@teclib.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2010 OCS Inventory contributors
Copyright (C) 2010-2012 FusionInventory Team
Copyright (C) 2011-2016 Teclib'

This software is licensed under the terms of GPLv2+, see LICENSE file for
details.

=cut
