package Armadito::Agent::Stdout::Parser;

use strict;
use warnings;
use English qw(-no_match_vars);
use UNIVERSAL::require;

require Exporter;

sub new {
	my ( $class, %params ) = @_;

	my %patterns;
	my $self = {
		patterns => \%patterns,
		logger   => $params{logger}
	};

	bless $self, $class;
	return $self;
}

sub getResults {
	my ($self) = @_;

	my $results  = {};
	my %patterns = %{ $self->{patterns} };

	foreach my $label ( keys(%patterns) ) {
		$results->{$label} = $patterns{$label}->{match};
	}

	return $results;
}

sub addPattern {
	my ( $self, $label, $regex ) = @_;

	my $pattern = {
		regex => $regex,
		match => ''
	};

	${ $self->{patterns} }{$label} = $pattern;
}

sub run {
	my ( $self, $input ) = @_;

	my @lines = split( /\n/, $input );

	foreach my $line (@lines) {
		$self->_parseLine($line);
	}

	return 1;
}

sub _parseLine {
	my ( $self, $line ) = @_;

	my %patterns = %{ $self->{patterns} };
	foreach my $label ( keys(%patterns) ) {
		$self->_checkPattern( $line, ${ $self->{patterns} }{$label} );
	}
}

sub _checkPattern {
	my ( $self, $line, $pattern ) = @_;

	if ( $line =~ m/$pattern->{regex}/ms ) {
		$pattern->{match} = $1;
	}
}

1;

__END__

=head1 NAME

Armadito::Agent::Patterns::Matcher - Parses an input string with multiple regular expressions.

=head1 DESCRIPTION

Given plain text content is parsed with multiple patterns. Each pattern should have capturing parentheses.

=head1 METHODS

=head2 $parser->new(%params)

New parser instanciation.

=head2 $parser->addPattern()

Add new pattern for parsing.

=head2 $parser->run()

Run parser on input given.

