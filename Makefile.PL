use strict;
use warnings;
use inc::Module::Install;
use English qw(-no_match_vars);

name 'Armadito-Agent';
include 'Module::AutoInstall';
abstract 'Armadito Agent for Linux and Windows';
license 'gpl';
repository 'https://github.com/armadito/armadito-agent';
version_from 'lib/Armadito/Agent.pm';
perl_version '5.008';
authors 'Teclib';

requires 'UNIVERSAL::require'    => '0';
requires 'HTTP::Request::Common' => '0';
requires 'HTTP::Request'         => '0';
requires 'URI::Escape'           => '0';
requires 'URI'                   => '0';
requires 'JSON'                  => '0';
requires 'Encode'                => '0';
requires 'Getopt::Long'          => '0';
requires 'Pod::Usage'            => '0';
requires 'XML::Bare'             => '0';
requires 'Readonly'              => '0';
requires 'Try::Tiny'             => '0';
requires 'Perl::Critic'          => '0';
requires 'Parse::Syslog'         => '0';
requires 'DBD::SQLite'           => '0';
requires 'Date::Calc'            => '0';
requires 'Time::Local'           => '0';
requires 'File::Stat'            => '0';

if ( $OSNAME eq "MSWin32" )
{
	requires 'Win32::OLE' => '0';
}

test_requires 'XML::TreePP'         => '0';
test_requires 'Test::Compile'       => '0';
test_requires 'Test::More'          => '0';
test_requires 'Test::Perl::Critic'  => '0';
test_requires 'Test::Code::TidyAll' => '0';

install_script 'bin/armadito-agent';

resources
	homepage   => "http://www.teclib-edition.com/en/teclib-products/armadito-antivirus/",
	bugtracker => "https://github.com/armadito/armadito-agent/issues",
	repository => "https://github.com/armadito/armadito-agent",
	IRC        => "http://webchat.freenode.net/#armadito";

makemaker_args(
	test => {
		TESTS => join ' ',
		map {glob}
			qw(
			t/*.t
			t/*/*.t
			t/*/*/*.t
			t/*/*/*/*.t
			t/*/*/*/*/*.t
			)
	},
	INSTALLMAN3DIR => 'none'
);

WriteAll;

# substitute prefix everywhere
$MY::Variables{SYSCONFDIR} =~ s/\$\(PREFIX\)/$MY::Variables{PREFIX}/;
$MY::Variables{DATADIR} =~ s/\$\(PREFIX\)/$MY::Variables{PREFIX}/;
$MY::Variables{LOCALSTATEDIR} =~ s/\$\(PREFIX\)/$MY::Variables{PREFIX}/;

my $ConfigFileMessage
	= -f "$MY::Variables{SYSCONFDIR}/agent.cfg"
	? "previous configuration file found, new one will be installed as agent.cfg.new"
	: "no previous configuration file found, new one will be installed as agent.cfg";

print <<EOF;

Installation summary
--------------------
prefix: $MY::Variables{PREFIX}
configuration installation directory: $MY::Variables{SYSCONFDIR}
constant data installation directory: $MY::Variables{DATADIR}
variable data installation directory: $MY::Variables{LOCALSTATEDIR}

$ConfigFileMessage
EOF

package MY;

use English qw(-no_match_vars);

our %Variables;

# force a perl-independant prefix for everything
sub constants {
	my ($self) = @_;

	if ( $OSNAME eq "MSWin32" ) {
		%Variables = (
			PREFIX               => 'C:\\Program Files\\Armadito-Agent',
			INSTALLSCRIPT        => '$(PREFIX)\\bin',
			INSTALLSITESCRIPT    => '$(PREFIX)\\bin',
			INSTALLVENDORSCRIPT  => '$(PREFIX)\\bin',
			INSTALLLIB           => '$(DATADIR)\\lib',
			INSTALLSITELIB       => '$(DATADIR)\\lib',
			INSTALLVENDORLIB     => '$(DATADIR)\\lib',
			INSTALLMAN1DIR       => '$(PREFIX)\\share\\man\\man1',
			INSTALLSITEMAN1DIR   => '$(PREFIX)\\share\\man\\man1',
			INSTALLVENDORMAN1DIR => '$(PREFIX)\\share\\man\\man1',
			INSTALLMAN3DIR       => '$(PREFIX)\\share\\man\\man3',
			INSTALLSITEMAN3DIR   => '$(PREFIX)\\share\\man\\man3',
			INSTALLVENDORMAN3DIR => '$(PREFIX)\\share\\man\\man3',
			SYSCONFDIR           => '$(PREFIX)\\etc',
			DATADIR              => '$(PREFIX)\\share',
			LOCALSTATEDIR        => '$(PREFIX)\\var',
		);
	}
	else {
		# for some reason, initialising Variables from the global scope doesn't work
		%Variables = (
			PREFIX               => '/usr/local',
			INSTALLSCRIPT        => '$(PREFIX)/bin',
			INSTALLSITESCRIPT    => '$(PREFIX)/bin',
			INSTALLVENDORSCRIPT  => '$(PREFIX)/bin',
			INSTALLLIB           => '$(DATADIR)/lib',
			INSTALLSITELIB       => '$(DATADIR)/lib',
			INSTALLVENDORLIB     => '$(DATADIR)/lib',
			INSTALLMAN1DIR       => '$(PREFIX)/share/man/man1',
			INSTALLSITEMAN1DIR   => '$(PREFIX)/share/man/man1',
			INSTALLVENDORMAN1DIR => '$(PREFIX)/share/man/man1',
			INSTALLMAN3DIR       => '$(PREFIX)/share/man/man3',
			INSTALLSITEMAN3DIR   => '$(PREFIX)/share/man/man3',
			INSTALLVENDORMAN3DIR => '$(PREFIX)/share/man/man3',
			SYSCONFDIR           => '$(PREFIX)/etc/armadito-agent',
			DATADIR              => '$(PREFIX)/share/armadito-agent',
			LOCALSTATEDIR        => '$(PREFIX)/var/armadito-agent',
		);
	}

	# allow Variables defined on command line to override defaults
	foreach my $name ( keys %Variables ) {
		$Variables{$name} = $self->{ARGS}->{$name} if $self->{ARGS}->{$name};
	}

	# get all standard MM Variables definitions, and override them if needed
	my @code = split( /\n/, $self->SUPER::constants(@_) );
	foreach my $line (@code) {

		# Skip comments
		next if $line =~ /^\s*#/;

		# Skip everything which isn't a var assignment.
		next unless $line =~ /^([A-Z0-9_]+) =/;
		my $name = $1;

		# skip Variables we're not interested
		next unless $Variables{$name};

		$line = "$name = $Variables{$name}";
	}

	# add out own Variables
	foreach my $name (qw/SYSCONFDIR DATADIR LOCALSTATEDIR/) {
		push @code, "$name = $Variables{$name}";
	}

	return join( "\n", @code );
}

sub install {
	my ($self) = @_;
	my $install = $self->SUPER::install(@_);

	# add dependency on data and configuration installation targets, and remove
	# dependency on perlocal installation target
	# depending on MakeMaker version, the line to match changes
	$install =~ s/install :: pure_install doc_install/install :: pure_install config_install data_install/;
	$install =~ s/install :: all pure_install doc_install/install :: all pure_install config_install data_install/;

	# suppress all lines related to packlist file installation
	$install =~ s/.*\.packlist \\\n//g;

	# add data and configuration installation targets
	if ( $OSNAME ne "MSWin32" ) {
		$install .= <<'EOF';

config_install :
	install -d -m 755 $(SYSCONFDIR)
	if [ -f $(SYSCONFDIR)/agent.cfg ]; then \
	    install -m 644 etc/agent.cfg $(SYSCONFDIR)/agent.cfg.new; \
	else \
	    install -m 644 etc/agent.cfg $(SYSCONFDIR)/agent.cfg; \
	fi

data_install :
	install -d -m 755 $(DATADIR)
	install -d -m 775 $(LOCALSTATEDIR)
EOF
	}
	else {
		$install .= <<'EOF';

config_install :
	if not exist "$(SYSCONFDIR)" mkdir "$(SYSCONFDIR)"
	if exist "$(SYSCONFDIR)\\agent.cfg" ( \
	    copy "etc\\agent.cfg" "$(SYSCONFDIR)\\agent.cfg.new"; \
	) else ( \
	    copy "etc\\agent.cfg" "$(SYSCONFDIR)\\agent.cfg"; \
	)

data_install :
	if not exist "$(DATADIR)" mkdir "$(DATADIR)"
	if not exist "$(INSTALLSCRIPT)" mkdir "$(INSTALLSCRIPT)"
	if exist "$(INSTALLSCRIPT)\\armadito-agent" @erase "$(INSTALLSCRIPT)\\armadito-agent"
	copy "bin\\armadito-agent" "$(INSTALLSCRIPT)\\armadito-agent"
EOF
	}

	return $install;
}

# ensure binaries get modified to use configured directories (on Unix only)
sub installbin {
	my ($self) = @_;
	my $installbin = $self->SUPER::installbin(@_);

	return $installbin if $OSNAME eq 'MSWin32';

	$installbin =~ s|\t\$\(FIXIN\) (.*)\n|\t\$(FIXIN) $1\n\t\$(FINALIZE) $1\n|g;

	$installbin .= <<'EOF';
FINALIZE = $(ABSPERLRUN) -pi \
    -e 's|use lib .*|use lib "$(DATADIR)/lib";|;' \
    -e 's|confdir => .*|confdir => "$(SYSCONFDIR)",|;' \
    -e 's|datadir => .*|datadir => "$(DATADIR)",|;' \
    -e 's|libdir  => .*|libdir  => "$(DATADIR)/lib",|;' \
    -e 's|vardir  => .*|vardir  => "$(LOCALSTATEDIR)",|' \
    --
EOF
	return $installbin;
}
