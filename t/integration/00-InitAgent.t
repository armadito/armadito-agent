use strict;
use warnings;

use Test::More 'no_plan';

use English qw(-no_match_vars);
use Getopt::Long;
use Pod::Usage;
use UNIVERSAL::require;
use IPC::System::Simple qw(capture);
use Data::Dumper;
use Try::Tiny;
use Cwd 'abs_path';

use Armadito::Agent;

sub initAgent {

	my $prefix = "";
	my %setup  = (
		confdir => $prefix . 'etc/',
		datadir => $prefix . 'share/',
		libdir  => $prefix . 'lib/',
		vardir  => $prefix . 'var/'
	);

	my $agent = Armadito::Agent->new(%setup);
}

my $options = { task => "Enrollment" };

try {
	initAgent();
}
catch {
	fail( $options->{task} );
	print STDERR $_;
};

pass( $options->{task} );

1;
