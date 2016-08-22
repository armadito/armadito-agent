use strict;
use warnings;

use Test::More;

## no critic
eval 'use Test::Code::TidyAll';
plan skip_all => "Test::Code::TidyAll required to check if the code is clean."
	if $@;
tidyall_ok();
