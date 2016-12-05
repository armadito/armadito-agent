package Armadito::Agent::Antivirus::Kaspersky::Win32;

use strict;
use warnings;
use English qw(-no_match_vars);
use Armadito::Agent::Tools::Dir qw( readDirectory );
use Armadito::Agent::Tools::Win32 qw( msFiletimeToUnix );
use DBD::SQLite;
use DBD::SQLite::Constants qw/:file_open/;

sub new {
	my ( $class, %params ) = @_;

	my $self = { logger => $params{logger}, };

	bless $self, $class;
	return $self;
}

sub getProgramPath {
	my ($self) = @_;

	my $install_path = $self->getInstallPath();

	if ( $self->_isProgramInDir($install_path) ) {
		return $self->{program_path};
	}

	return "";
}

sub getInstallPath {
	my ($self) = @_;

	my @programfiles_paths = ( "C:\\Program Files (X86)", "C:\\Program Files" );
	foreach my $path (@programfiles_paths) {
		if ( -d $path . "\\Kaspersky Lab" ) {
			return $path . "\\Kaspersky Lab";
		}
	}
}

sub _isProgramInDir {
	my ( $self, $path, $program ) = @_;

	my @entries = readDirectory(
		dirpath => $path,
		filter  => "dirs-only"
	);

	foreach my $entry (@entries) {
		if ( $entry =~ m/^Kaspersky Anti-Virus.*/ ) {
			$self->{logger}->info($entry);
			$self->{program_path} = $path . "\\" . $entry;
			return 1;
		}
	}

	return 0;
}

sub getAlerts {
	my ($self) = @_;

	my $dbfile = "C:\\ProgramData\\Kaspersky Lab\\AVP17.0.0\\Data\\detects.db";
	if ( !-r $dbfile ) {
		die "Unreadable detects.db file : $dbfile\n";
	}

	my $dbh = DBI->connect(
		"dbi:SQLite:$dbfile",
		undef, undef,
		{
			sqlite_open_flags => SQLITE_OPEN_READONLY,
		}
	) or die "DBI connection failed to dbi:SQLite:$dbfile ; $DBI::errstr";

	my $stmt = qq(SELECT Id, Threat, Time from detects;);
	my $sth  = $dbh->prepare($stmt);
	my $rv   = $sth->execute() or die $DBI::errstr;
	if ( $rv < 0 ) {
		print $DBI::errstr;
	}

	my $alerts = [];

	while ( my @row = $sth->fetchrow_array() ) {
		my $threat_id   = $row[1];
		my $filetime_ts = $row[2];

		my $alert = {
			name           => $self->getThreatName( $threat_id, $dbh ),
			filepath       => $self->getFilePath( $threat_id,   $dbh ),
			detection_time => msFiletimeToUnix($filetime_ts) + 3600
		};

		push( @$alerts, $alert );
	}

	$dbh->disconnect();
	return $alerts;
}

sub getFilePath {
	my ( $self, $threat_id, $dbh ) = @_;

	my $stmt = qq(SELECT Name FROM objects WHERE Id=?;);
	my $sth  = $dbh->prepare($stmt);
	my $rv   = $sth->execute($threat_id) or die $DBI::errstr;
	if ( $rv < 0 ) {
		print $DBI::errstr;
	}

	my @row = $sth->fetchrow_array();
	return $row[0];
}

sub getThreatName {
	my ( $self, $threat_id, $dbh ) = @_;

	my $verdict_id = $self->getVerdictId( $threat_id, $dbh );

	my $stmt = qq(SELECT Name FROM verdicts WHERE Id=?;);
	my $sth  = $dbh->prepare($stmt);
	my $rv   = $sth->execute($verdict_id) or die $DBI::errstr;
	if ( $rv < 0 ) {
		print $DBI::errstr;
	}

	my @row = $sth->fetchrow_array();
	return $row[0];
}

sub getVerdictId {
	my ( $self, $threat_id, $dbh ) = @_;

	my $stmt = qq(SELECT Verdict FROM threats WHERE Id=?;);
	my $sth  = $dbh->prepare($stmt);
	my $rv   = $sth->execute($threat_id) or die $DBI::errstr;
	if ( $rv < 0 ) {
		print $DBI::errstr;
	}

	my @row = $sth->fetchrow_array();
	return $row[0];
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Win32 - Win32 Specific code for Kaspersky Antivirus

=head1 DESCRIPTION

This class regroup all Kaspersky's Windows stuff.

=head1 FUNCTIONS

=head2 new ( $self, %params )

Instanciate module.

=head2 getProgramPath ( $self )

Return the path where Kaspersky AV is installed.

