package TestAgent;

use strict;
use warnings;

use Armadito::Agent;

use lib 't/tests';
use Agent::TestAntivirus;

sub new {

	my ( $class, %params ) = @_;
	my $prefix = "";
	my %setup  = (
		confdir => $prefix . 'etc/',
		datadir => $prefix . 'share/',
		libdir  => $prefix . 'lib/',
		vardir  => $prefix . 'var/'
	);

	my $self = { agent => Armadito::Agent->new(%setup) };

	bless $self, $class;
	return $self;
}

sub init {
	my ($self) = @_;

	$self->{agent}->{config} = Armadito::Agent::Config->new();
	$self->{agent}->{config}->loadDefaults( $self->{agent}->_getDefaultConf() );
	$self->{agent}->{key}          = "AAAAF-111AF-DZ78F-EE78F-DDD1F";
	$self->{agent}->{agent_id}     = 0;
	$self->{agent}->{scheduler_id} = 0;

	my $testantivirus = Agent::TestAntivirus->new();
	$self->{agent}->{antivirus} = $testantivirus->{antivirus};
}

1;
