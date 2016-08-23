use strict;
use warnings;
use Test::Compile;
use English qw(-no_match_vars);
use UNIVERSAL::require;

BEGIN {
	my $libdir = "";
	if ( $OSNAME eq 'MSWin32' ) {
		my $Registry;
		Win32::TieRegistry->require();
		Win32::TieRegistry->import(
			Delimiter   => '/',
			ArrayValues => 0,
			TiedRef     => \$Registry
		);

		my $machKey = $Registry->Open(
			'LMachine',
			{
				Access => Win32::TieRegistry::KEY_READ()
			}
		) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

		my $uninstallValues = $machKey->{'SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/FusionInventory-Agent'};
		die
			"FusionInventory-Agent InstallLocation registry key not found. Please install FusionInventory-Agent (2.3.17+)"
			unless $uninstallValues;

		my $installLocation = $uninstallValues->{'/InstallLocation'};
		die
			"FusionInventory-Agent InstallLocation registry key not found. Please install FusionInventory-Agent (2.3.17+)"
			unless $installLocation;

		$libdir = $installLocation . "\\perl\\agent\\";
		use lib "../share/armadito-agent/lib";
	}
	else {
		# Set up fusioninventory agent libdir
		my $setup = `fusioninventory-agent --setup`;
		die
			"fusioninventory-agent --setup not available. Please, install fusioninventory-agent (2.3.5+) before retrying."
			if ( $setup !~ /libdir: (.*?)\n/ms );
		$libdir = $1;
	}

	# If ok, we add libdir to @INC
	die "FusionInventoryAgent libs not found. Please, install fusioninventory-agent before retrying."
		if ( !-f $libdir . "/FusionInventory/Agent.pm" );
	push( @INC, $libdir );
}

my @scripts = qw(mod2html podtree2html pods2html perl2html);
my $test    = Test::Compile->new();
$test->all_files_ok();
$test->pl_file_compiles($_) for @scripts;
$test->done_testing();

1;