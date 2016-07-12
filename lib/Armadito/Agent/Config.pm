package Armadito::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;
use UNIVERSAL::require;

my $default_armadito = {
    'ca-cert-dir'             => undef,
    'ca-cert-file'            => undef,
    'color'                   => undef,
    'conf-reload-interval'    => 0,
    'debug'                   => undef,
    'force'                   => undef,
    'html'                    => undef,
    'local'                   => undef,
    'logger'                  => 'Stderr',
    'logfile'                 => undef,
    'logfacility'             => 'LOG_USER',
    'logfile-maxsize'         => undef,
    'no-ssl-check'            => undef,
    'proxy'                   => undef,
    'server'                  => undef,
    'stdout'                  => undef
};

my $default_fusion = {
    'additional-content'      => undef,
    'backend-collect-timeout' => 180,
    'ca-cert-dir'             => undef,
    'ca-cert-file'            => undef,
    'color'                   => undef,
    'conf-reload-interval'    => 0,
    'debug'                   => undef,
    'delaytime'               => 3600,
    'force'                   => undef,
    'html'                    => undef,
    'lazy'                    => undef,
    'local'                   => undef,
    'logger'                  => 'Stderr',
    'logfile'                 => undef,
    'logfacility'             => 'LOG_USER',
    'logfile-maxsize'         => undef,
    'no-category'             => [],
    'no-httpd'                => undef,
    'no-ssl-check'            => undef,
    'no-task'                 => [],
    'no-p2p'                  => undef,
    'password'                => undef,
    'proxy'                   => undef,
    'httpd-ip'                => undef,
    'httpd-port'              => 62354,
    'httpd-trust'             => [],
    'scan-homedirs'           => undef,
    'scan-profiles'           => undef,
    'server'                  => undef,
    'tag'                     => undef,
    'tasks'                   => undef,
    'timeout'                 => 180,
    'user'                    => undef,
    # deprecated options
    'stdout'                  => undef,
};


sub new {
    my ($class, %params) = @_;

    my $self = {
		fusion => undef,
		armadito => undef
	};
    bless $self, $class;

	# Load fusioninventory configuration
	$self->_loadDefaults("FusionInventory-Agent");
	$self->_loadFromBackend($params{options}->{'conf-fusion-file'}, $params{options}->{'conf-fusion'}, "", "FusionInventory-Agent");

	# Load armadito agent configuration
	$self->_loadDefaults("Armadito-Agent");
	$self->_loadFromBackend($params{options}->{'conf-armadito-file'}, $params{options}->{'conf-armadito'}, $params{confdir}, "Armadito-Agent");

    return $self;
}

sub _loadDefaults {
    my ($self, $agent_type) = @_;

	if($agent_type eq "FusionInventory-Agent"){
		foreach my $key (keys %$default_fusion) {
		    $self->{fusion}->{$key} = $default_fusion->{$key};
		}
	}
	elsif($agent_type eq "Armadito-Agent"){
		foreach my $key (keys %$default_armadito) {
		    $self->{armadito}->{$key} = $default_armadito->{$key};
		}
	}
}

sub _loadFromBackend {
    my ($self, $confFile, $config, $confdir, $agent_type) = @_;

    my $backend =
        $confFile            ? 'file'      :
        $config              ? $config     :
        $OSNAME eq 'MSWin32' ? 'registry'  :
                               'file';

	print "BACKEND : $backend\n";

    SWITCH: {
        if ($backend eq 'registry') {
            die "Unavailable configuration backend\n"
                unless $OSNAME eq 'MSWin32';
            $self->_loadFromRegistry();
            last SWITCH;
        }

        if ($backend eq 'file') {
            $self->_loadFromFile({
                file      => $confFile,
                directory => $confdir,
            }, $agent_type);
            last SWITCH;
        }

        if ($backend eq 'none') {
            last SWITCH;
        }

        die "Unknown configuration backend '$backend'\n";
    }
}

sub _loadFromRegistry { # TOBETESTED
    my ($self, $agent_type) = @_;

    my $Registry;
    Win32::TieRegistry->require();
    Win32::TieRegistry->import(
        Delimiter   => '/',
        ArrayValues => 0,
        TiedRef     => \$Registry
    );

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ()
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $settings = $machKey->{"SOFTWARE/".$agent_type};

    foreach my $rawKey (keys %$settings) {
        next unless $rawKey =~ /^\/(\S+)/;
        my $key = lc($1);
        my $val = $settings->{$rawKey};
        # Remove the quotes
        $val =~ s/\s+$//;
        $val =~ s/^'(.*)'$/$1/;
        $val =~ s/^"(.*)"$/$1/;

		if($agent_type eq "FusionInventory-Agent"){
        	if (exists $default_fusion->{$key}) {
            	$self->{fusion}->{$key} = $val;
			}
		}
		elsif($agent_type eq "Armadito-Agent"){
			if (exists $default_armadito->{$key}) {
				$self->{armadito}->{$key} = $val;
			}
        } else {
            warn "unknown configuration directive $key";
        }
    }
}

sub _loadFromFile {
    my ($self, $params, $agent_type) = @_;
    my $file = $params->{file} ?
        $params->{file} : $params->{directory} . '/agent.cfg';

    if ($file) {
        die "non-existing file $file" unless -f $file;
        die "non-readable file $file" unless -r $file;
    } else {
        die "no configuration file";
    }

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Config: Failed to open $file: $ERRNO";
        return;
    }

    while (my $line = <$handle>) {
        $line =~ s/#.+//;
        if ($line =~ /([\w-]+)\s*=\s*(.+)/) {
            my $key = $1;
            my $val = $2;

            # Remove the quotes
            $val =~ s/\s+$//;
            $val =~ s/^'(.*)'$/$1/;
            $val =~ s/^"(.*)"$/$1/;

			if($agent_type eq "FusionInventory-Agent"){
		    	if (exists $default_fusion->{$key}) {
		        	$self->{fusion}->{$key} = $val;
				}
			}
			elsif($agent_type eq "Armadito-Agent"){
				if (exists $default_armadito->{$key}) {
					$self->{armadito}->{$key} = $val;
				}
		    } else {
		        warn "unknown configuration directive $key";
		    }
        }
    }
    close $handle;
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
