package Armadito::Agent::XML::Parser;

use strict;
use warnings;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use XML::Bare;

require Exporter;

sub new {
	my ( $class, %params ) = @_;

	warn "Empty xml content." if !$params{text};

	my $xmlparser = XML::Bare->new( text => $params{text} );

	my $self = {
		parser    => $xmlparser,
		xmlparsed => ""
	};

	bless $self, $class;
	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	eval { $self->{xmlparsed} = $self->{parser}->parse() };
	if ($@) {
		warn "Error when parsing XML alert " . $@;
		return 0;
	}

	return 1;
}
1;

__END__

=head1 NAME

Armadito::Agent::XML::Parser - simple XML parser class using XML::Bare module.

=head1 DESCRIPTION

Given plain text content is parsed with XML::Bare.

=head1 METHODS

=head2 $parser->new(%params)

New parser instanciation.

=over

=item I<text>

Plain text input to be parsed with XML::Bare.

=back

=head2 $parser->run()

Run parser on input given.

