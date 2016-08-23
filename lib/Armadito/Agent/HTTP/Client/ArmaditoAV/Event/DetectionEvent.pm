package Armadito::Agent::HTTP::Client::ArmaditoAV::Event::DetectionEvent;

sub new {
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	return $self;
}
1;

__END__

=head1 NAME

Armadito::Agent::HTTP::Client::ArmaditoAV::Event::DetectionEvent - ArmaditoAV DetectionEvent class

=head1 DESCRIPTION

This is the class dedicated to DetectionEvent of ArmaditoAV api.

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run event related stuff.

=head2 new ( $self, %params )

Instanciate this class.

