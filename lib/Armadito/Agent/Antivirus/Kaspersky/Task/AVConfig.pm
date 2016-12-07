package Armadito::Agent::Antivirus::Kaspersky::Task::AVConfig;

use strict;
use warnings;
use base 'Armadito::Agent::Task::AVConfig';
use XML::LibXML;
use Data::Dumper;

sub run {
	my ( $self, %params ) = @_;
	
	$self = $self->SUPER::run(%params);
	$self->_parseConfigFile();
	$self->_sendToGLPI();
}

sub _getConfigFilePath {
	my ($self) = @_;

	my $class = "Armadito::Agent::Antivirus::Kaspersky::Win32";
	$class->require();
	my $osclass = $class->new( logger => $self->{logger} );

	return $osclass->getDataPath() . "profiles.xml";
}

sub _parseConfigFile {
	my ($self) = @_;

	my $config_file = $self->_getConfigFilePath();
	my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($config_file);

	my ($profiles)  = $doc->findnodes('/propertiesmap/key');
	$self->_parseKeyNode($profiles, "");
}

sub _parseKeyNode {
	my ($self, $node, $path) = @_;	
	
	foreach ($node->findnodes('./key')) {
		$self->_parseKeyNode($_, $path.":".$_->getAttribute('name'));
	}

	foreach ($node->findnodes('./tDWORD')) {
		$self->_addConfEntry($path.":".$_->getAttribute('name'), $_->to_literal);
	}
	
	foreach ($node->findnodes('./tSTRING')) {
		$self->_addConfEntry($path.":".$_->getAttribute('name'), $_->to_literal);
	}
}

1;

__END__

=head1 NAME

Armadito::Agent::Antivirus::Kaspersky::Task::AVConfig - AVConfig Task for Kaspersky Antivirus.

=head1 DESCRIPTION

This task inherits from L<Armadito::Agent::Task:AVConfig>. Get Antivirus configuration and then send it in a json formatted POST request to Armadito plugin for GLPI.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.
