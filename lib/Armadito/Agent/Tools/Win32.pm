package Armadito::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';
use utf8;

use threads;
use threads 'exit' => 'threads_only';
use threads::shared;

use constant KEY_WOW64_64 => 0x100;
use constant KEY_WOW64_32 => 0x200;

use UNIVERSAL::require;
use English qw(-no_match_vars);
use File::Temp qw(:seekable tempfile);
use File::Basename qw(basename);

BEGIN {
	if ( $^O ne "MSWin32" ) {

		# Test ::Compile exception
		exit(0);
	}
}

use Win32::Job;
use Win32::TieRegistry (
	Delimiter   => '/',
	ArrayValues => 0,
	qw/KEY_READ/
);

our @EXPORT = qw(
	getRegistryValue
	getRegistryKey
	getWMIObjects
);

sub getWMIObjects {
	my $win32_ole_dependent_api = {
		array => 1,
		funct => '_getWMIObjects',
		args  => \@_
	};

	return _call_win32_ole_dependent_api($win32_ole_dependent_api);
}

sub _getWMIObjects {
	my (%params) = @_;

	$params{moniker} = 'winmgmts:{impersonationLevel=impersonate,(security)}!//./';

	my $WMIService = Win32::OLE->GetObject( $params{moniker} );

	# Support alternate moniker if provided and main failed to open
	unless ( defined($WMIService) ) {
		if ( $params{altmoniker} ) {
			$WMIService = Win32::OLE->GetObject( $params{altmoniker} );
		}
		return unless ( defined($WMIService) );
	}

	Win32::OLE->use('in');

	my @objects;
	foreach my $instance (
		in(
			  $params{query}
			? $WMIService->ExecQuery( @{ $params{query} } )
			: $WMIService->InstancesOf( $params{class} )
		)
		)
	{
		my $object;

		# Handle Win32::OLE object method, see _getLoggedUsers() method in
		# use or enhance this feature
		if ( $params{method} ) {
			my @invokes = ( $params{method} );
			my %results = ();

			# Prepare Invoke params for known requested types
			foreach my $name ( @{ $params{params} } ) {
				my ( $type, $default ) = @{ $params{$name} }
					or next;
				my $variant;
				if ( $type eq 'string' ) {
					Win32::OLE::Variant->use(qw/VT_BYREF VT_BSTR/);
					eval { $variant = VT_BYREF() | VT_BSTR(); };
				}
				eval { $results{$name} = Win32::OLE::Variant::Variant( $variant, $default ); };
				push @invokes, $results{$name};
			}

			# Invoke the method saving the result so we can also bind it
			eval { $results{ $params{method} } = $instance->Invoke(@invokes); };

			# Bind results to object to return
			foreach my $name ( keys( %{ $params{binds} } ) ) {
				next unless ( defined( $results{$name} ) );
				my $bind = $params{binds}->{$name};
				eval { $object->{$bind} = $results{$name}->Get(); };
				if ( defined $object->{$bind} && !ref( $object->{$bind} ) ) {
					utf8::upgrade( $object->{$bind} );
				}
			}
		}
		foreach my $property ( @{ $params{properties} } ) {
			if ( defined $instance->{$property} && !ref( $instance->{$property} ) ) {

				# string value
				$object->{$property} = $instance->{$property};

				# despite CP_UTF8 usage, Win32::OLE downgrades string to native
				# encoding, if possible, ie all characters have code <= 0x00FF:
				# http://code.activestate.com/lists/perl-win32-users/Win32::OLE::CP_UTF8/
				utf8::upgrade( $object->{$property} );
			}
			elsif ( defined $instance->{$property} ) {

				# list value
				$object->{$property} = $instance->{$property};
			}
			else {
				$object->{$property} = undef;
			}
		}
		push @objects, $object;
	}

	return @objects;
}

sub getRegistryValue {
	my (%params) = @_;

	my ( $root, $keyName, $valueName );
	if ( $params{path} =~ m{^(HKEY_\S+)/(.+)/([^/]+)} ) {
		$root      = $1;
		$keyName   = $2;
		$valueName = $3;
	}
	else {
		$params{logger}->error("Failed to parse '$params{path}'. Does it start with HKEY_?") if $params{logger};
		return;
	}

	my $key = _getRegistryKey(
		logger  => $params{logger},
		root    => $root,
		keyName => $keyName
	);

	return unless ( defined($key) );

	if ( $valueName eq '*' ) {
		my %ret;
		foreach ( keys %$key ) {
			s{^/}{};
			$ret{$_} = $params{withtype} ? [ $key->GetValue($_) ] : $key->{"/$_"};
		}
		return \%ret;
	}
	else {
		return $params{withtype} ? [ $key->GetValue($valueName) ] : $key->{"/$valueName"};
	}
}

sub getRegistryKey {
	my (%params) = @_;

	my ( $root, $keyName );
	if ( $params{path} =~ m{^(HKEY_\S+)/(.+)} ) {
		$root    = $1;
		$keyName = $2;
	}
	else {
		$params{logger}->error("Failed to parse '$params{path}'. Does it start with HKEY_?") if $params{logger};
		return;
	}

	return _getRegistryKey(
		logger  => $params{logger},
		root    => $root,
		keyName => $keyName
	);
}

sub _getRegistryKey {
	my (%params) = @_;

	## no critic (ProhibitBitwise)
	my $rootKey
		= is64bit()
		? $Registry->Open( $params{root}, { Access => KEY_READ | KEY_WOW64_64 } )
		: $Registry->Open( $params{root}, { Access => KEY_READ } );

	if ( !$rootKey ) {
		$params{logger}->error("Can't open $params{root} key: $EXTENDED_OS_ERROR") if $params{logger};
		return;
	}
	my $key = $rootKey->Open( $params{keyName} );

	return $key;
}

my $worker;
my $worker_semaphore;

my @win32_ole_calls : shared;

sub start_Win32_OLE_Worker {

	unless ( defined($worker) ) {

		# Request a semaphore on which worker blocks immediatly
		Thread::Semaphore->require();
		$worker_semaphore = Thread::Semaphore->new(0);

		# Start a worker thread
		$worker = threads->create( \&_win32_ole_worker );
	}
}

sub _win32_ole_worker {

	# Load Win32::OLE as late as possible in a dedicated worker
	Win32::OLE->require()          or return;
	Win32::OLE::Variant->require() or return;
	Win32::OLE->Option( CP => Win32::OLE::CP_UTF8() );

	while (1) {

		# Always block until semaphore is made available by main thread
		$worker_semaphore->down();

		my ( $call, $result );
		{
			lock(@win32_ole_calls);
			$call = shift @win32_ole_calls
				if (@win32_ole_calls);
		}

		if ( defined($call) ) {
			lock($call);

			# Found requested private function and call it as expected
			my $funct;
			eval {
				no strict 'refs';    ## no critic (ProhibitNoStrict)
				$funct = \&{ $call->{'funct'} };
			};
			if ( exists( $call->{'array'} ) && $call->{'array'} ) {
				my @results = &{$funct}( @{ $call->{'args'} } );
				$result = \@results;
			}
			else {
				$result = &{$funct}( @{ $call->{'args'} } );
			}

			# Share back the result
			$call->{'result'} = shared_clone($result);

			# Signal main thread result is available
			cond_signal($call);
		}
	}
}

sub _call_win32_ole_dependent_api {
	my ($call) = @_
		or return;

	if ( defined($worker) ) {

		# Share the expect call
		my $call = shared_clone($call);
		my $result;

		if ( defined($call) ) {

			# Be sure the worker block
			$worker_semaphore->down_nb();

			# Lock list calls before releasing semaphore so worker waits
			# on it until we start cond_timedwait for signal on $call
			lock(@win32_ole_calls);
			push @win32_ole_calls, $call;

			# Release semaphore so the worker can continue its job
			$worker_semaphore->up();

			# Now, wait for worker result with one minute timeout
			my $timeout = time + 60;
			while ( !exists( $call->{'result'} ) ) {
				last if ( !cond_timedwait( $call, $timeout, @win32_ole_calls ) );
			}

			# Be sure to always block worker on semaphore from now
			$worker_semaphore->down_nb();

			if ( exists( $call->{'result'} ) ) {
				$result = $call->{'result'};
			}
			else {
				# Worker is failing: get back to mono-thread and pray
				$worker->detach();
				$worker = undef;
				return _call_win32_ole_dependent_api(@_);
			}
		}

		return ( exists( $call->{'array'} ) && $call->{'array'} ) ? @{ $result || [] } : $result;
	}
	else {
		# Load Win32::OLE as late as possible
		Win32::OLE->require()          or return;
		Win32::OLE::Variant->require() or return;
		Win32::OLE->Option( CP => Win32::OLE::CP_UTF8() );

		# We come here from worker or if we failed to start worker
		my $funct;
		eval {
			no strict 'refs';    ## no critic (ProhibitNoStrict)
			$funct = \&{ $call->{'funct'} };
		};
		return &{$funct}( @{ $call->{'args'} } );
	}
}

sub getUsersFromRegistry {
	my (%params) = @_;

	my $logger = $params{logger};

	# ensure native registry access, not the 32 bit view
	my $flags = is64bit() ? KEY_READ | KEY_WOW64_64 : KEY_READ;
	my $machKey = $Registry->Open(
		'LMachine',
		{
			Access => $flags
		}
	) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
	if ( !$machKey ) {
		$logger->error("getUsersFromRegistry() : Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
		return;
	}
	$logger->debug2('getUsersFromRegistry() : opened LMachine registry key');
	my $profileList = $machKey->{"SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProfileList"};
	next unless $profileList;

	my $userList;
	foreach my $profileName ( keys %$profileList ) {
		$params{logger}->debug2( 'profileName : ' . $profileName );
		next unless $profileName =~ m{/$};
		next unless length($profileName) > 10;
		my $profilePath = $profileList->{$profileName}{'/ProfileImagePath'};
		my $sid         = $profileList->{$profileName}{'/Sid'};
		next unless $sid;
		next unless $profilePath;
		my $user = basename($profilePath);
		$userList->{$profileName} = $user;
	}

	if ( $params{logger} ) {
		$params{logger}->debug2( 'getUsersFromRegistry() : retrieved ' . scalar( keys %$userList ) . ' users' );
	}
	return $userList;
}

END {
	# Just detach worker
	$worker->detach() if ( defined($worker) && !$worker->is_detached() );
}

1;
__END__

=head1 NAME

Armadito::Agent::Tools::Win32 - Windows generic functions

=head1 DESCRIPTION

This module provides some Windows-specific generic functions.

=head1 FUNCTIONS

=head2 is64bit()

Returns true if the OS is 64bit or false.

=head2 getWMIObjects(%params)

Returns the list of objects from given WMI class or from a query, with given
properties, properly encoded.

=over

=item moniker a WMI moniker (default: winmgmts:{impersonationLevel=impersonate,(security)}!//./)

=item altmoniker another WMI moniker to use if first failed (none by default)

=item class a WMI class, not used if query parameter is also given

=item properties a list of WMI properties

=item query a WMI request to execute, if specified, class parameter is not used

=item method an object method to call, in that case, you will also need the
following parameters:

=item params a list ref to the parameters to use fro the method. This list contains
string as key to other parameters defining the call. The key names should not
match any exiting parameter definition. Each parameter definition must be a list
of the type and default value.

=item binds a hash ref to the properties to bind to the returned object

=back

=head2 encodeFromRegistry($string)

Ensure given registry content is properly encoded to utf-8.

=head2 getRegistryValue(%params)

Returns a value from the registry.

=over

=item path a string in hive/key/value format

E.g: HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProductName

=item logger

=back

=head2 getRegistryKey(%params)

Returns a key from the registry. If key name is '*', all the keys of the path are returned as a hash reference.

=over

=item path a string in hive/key format

E.g: HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion

=item logger

=back

=head2 start_Win32_OLE_Worker()

Under win32, just start a worker thread handling Win32::OLE dependent
APIs like is64bit() & getWMIObjects(). This is sometime needed to avoid
perl crashes.
