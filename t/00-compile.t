use strict;
use warnings;

use Test::More;
use Test::Compile;
use English qw(-no_match_vars);

my @scripts = qw(mod2html podtree2html pods2html perl2html);

if ( $Test::Compile::VERSION =~ /^0\.\d+/ )
{
	all_pm_files_ok();
	done_testing();
}
else {
	my $test = Test::Compile->new();
	$test->all_files_ok();
	$test->pl_file_compiles($_) for @scripts;
	$test->done_testing();
}
1;
