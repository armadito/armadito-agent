package Armadito::Agent::Antivirus::Kaspersky::Task::State;

use strict;
use warnings;
use base 'Armadito::Agent::Task::State';
use Armadito::Agent::Tools::File qw(readFile);
use XML::Simple;
use Time::Local;

sub run {
	my ( $self, %params ) = @_;
	$self = $self->SUPER::run(%params);

	$self->{data} = {
		dbinfo    => {},
		avdetails => []
	};

	$self->_parseUpdateIndex();
	$self->_parseProfilesFile();

	$self->_sendToGLPI( $self->{data} );
}

sub _getUpdateIndexPath {
	my ($self) = @_;

	my $osclass = $self->{agent}->{antivirus}->getOSClass();
	return $osclass->getDataPath() . "u1313g.xml";
}

sub _parseUpdateIndex {
	my ($self) = @_;

	my $update_index = $self->_getUpdateIndexPath();
	my $filecontent = readFile( filepath => $update_index );
	$filecontent =~ s/(.*);.*$/$1/ms;
	my $xml = XMLin($filecontent);

	$self->{data}->{dbinfo} = $self->_getDatabasesInfo($xml);
}

sub _getDatabasesInfo {
	my ( $self, $xml ) = @_;

	my $dbinfo = {
		global_update_timestamp => $self->_toTimestamp( $xml->{Date} ),
		modules                 => $self->_getModulesInfo($xml)
	};

	return $dbinfo;
}

sub _getModulesInfo {
	my ( $self, $xml ) = @_;

	my @mod_simple    = $self->_getModulesSimpleIndexes($xml);
	my @mod_multiple  = $self->_getModulesMultipleIndexes($xml);
	my @modules_infos = ( @mod_simple, @mod_multiple );

	return \@modules_infos;
}

sub _getModulesSimpleIndexes {
	my ( $self, $xml ) = @_;

	my @modules = ();
	foreach ( @{ $xml->{Index} } ) {
		my $module_info = {
			name                 => $_->{Name},
			mod_status           => "up-to-date",
			mod_update_timestamp => $self->_toTimestamp( $_->{Date} ),
			bases                => []
		};

		push( @modules, $module_info );
	}

	return @modules;
}

sub _getModulesMultipleIndexes {
	my ( $self, $xml ) = @_;

	my @modules = ();
	foreach ( @{ $xml->{Indexes} } ) {
		my @itemkeys = split( ';', $_->{Item} );
		my @list     = split( ';', $_->{List} );

		foreach my $module (@list) {
			my @items = split( '\|', $module );
			my $kmodule_info = {};

			for ( my $i = 0; $i < scalar(@items); $i++ ) {
				$kmodule_info->{ $itemkeys[$i] } = $items[$i];
			}

			my $module_info = {
				name                 => $kmodule_info->{Name},
				mod_status           => "up-to-date",
				mod_update_timestamp => $self->_toTimestamp( $kmodule_info->{Date} ),
				bases                => []
			};

			push( @modules, $module_info );
		}
	}

	return @modules;
}

sub _toTimestamp {
	my ( $self, $date ) = @_;

	if ( $date =~ m/^(\d{2})(\d{2})(\d{4}) (\d{2})(\d{2})/ ) {
		my ( $mday, $mon, $year, $hour, $min, $sec ) = ( $1, $2, $3, $4, $5, "00" );
		return timelocal( $sec, $min, $hour, $mday, $mon - 1, $year );
	}

	return 0;
}

sub _getProfilesFilePath {
	my ($self) = @_;

	my $osclass = $self->{agent}->{antivirus}->getOSClass();
	return $osclass->getDataPath() . "profiles.xml";
}

sub _parseProfilesFile {
	my ($self) = @_;

	my $config_file = $self->_getProfilesFilePath();
	my $parser      = XML::LibXML->new();
	my $doc         = $parser->parse_file($config_file);

	my ($profiles) = $doc->findnodes('/propertiesmap/key');
	$self->_parseKeyNode( $profiles, "" );
}

sub _parseKeyNode {
	my ( $self, $node, $path ) = @_;

	foreach ( $node->findnodes('./key') ) {
		$self->_parseKeyNode( $_, $path . ":" . $_->getAttribute('name') );
	}

	foreach ( $node->findnodes('./tDWORD') ) {
		$self->_addAVDetail( $path . ":" . $_->getAttribute('name'), $_->to_literal );
	}

	foreach ( $node->findnodes('./tSTRING') ) {
		$self->_addAVDetail( $path . ":" . $_->getAttribute('name'), $_->to_literal );
	}
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::State - State Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:State>. Get Antivirus state and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.
