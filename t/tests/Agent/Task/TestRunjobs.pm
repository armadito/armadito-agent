package Agent::Task::TestRunjobs;

use strict;
use warnings;

sub new {
	my ( $class, %params ) = @_;

	my $self = { jobs => [] };

	bless $self, $class;
	return $self;
}
1;
