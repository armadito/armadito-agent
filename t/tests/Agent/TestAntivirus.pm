package Agent::TestAntivirus;

use strict;
use warnings;

use Armadito::Agent::Antivirus;

sub new {
	my ( $class, %params ) = @_;

	my $antivirus = Armadito::Agent::Antivirus->new();
	$antivirus->{name}         = "TestAV";
	$antivirus->{version}      = "1.0.1";
	$antivirus->{scancli_path} = "/usr/bin/avtest-scan-cli";

	my $self = { antivirus => $antivirus };

	bless $self, $class;
	return $self;
}

1;
