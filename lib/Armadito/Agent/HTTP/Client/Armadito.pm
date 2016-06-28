package Armadito::Agent::HTTP::Client::Armadito;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use English qw(-no_match_vars);
use HTTP::Request;
use HTTP::Request::Common qw{ POST };
use UNIVERSAL::require;
use URI;
use Encode;
use Data::Dumper;
use URI::Escape;

use Armadito::Agent::Tools;

sub new {
   my ($class, %params) = @_;
   my $self = $class->SUPER::new(%params);

   return $self;
}

sub _prepareVal {
    my ($self, $val) = @_;

    return '' unless length($val);

    # forbid too long argument.
    while (length(URI::Escape::uri_escape_utf8($val)) > 1500) {
        $val =~ s/^.{5}/…/;
    }

    return URI::Escape::uri_escape_utf8($val);
}

sub _prepareURL {
    my ($self, %params) = @_;

    my $url = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});

    if ($params{method} eq 'GET'){

       my $urlparams = 'action='.uri_escape($params{args}->{action});

       foreach my $k (keys %{$params{args}}) {
	 if (ref($params{args}->{$k}) eq 'ARRAY') {
	    foreach (@{$params{args}->{$k}}) {
	        $urlparams .= '&'.$k.'[]='.$self->_prepareVal($_ || '');
	    }
	} elsif (ref($params{args}->{$k}) eq 'HASH') {
	    foreach (keys %{$params{args}->{$k}}) {
	        $urlparams .= '&'.$k.'['.$_.']='.$self->_prepareVal($params{args}->{$k}{$_});
	    }
	} elsif ($k ne 'action' && length($params{args}->{$k})) {
	    $urlparams .= '&'.$k.'='.$self->_prepareVal($params{args}->{$k});
	}
       }

       $url .= '?'.$urlparams;
     }

     return $url;
}

sub send { 
    my ($self, %params) = @_;

    my $url = $self->_prepareURL(%params);
   
    $self->{logger}->debug2($url) if $self->{logger};

    my $headers = HTTP::Headers->new(
            'Content-Type' => 'application/json',
            'Referer'      => $url
    );

    my $request = HTTP::Request->new(
            $params{method} => $url,
	    $headers
    );
   
    if($params{message} && $params{method} eq 'POST'){
        # json utf-8 encoded
        $request->content(encode('UTF-8',$params{message}));
    }

    return $self->request($request);
}


1;
__END__

=head1 NAME

Armadito::Agent::HTTP::Client::Armadito - An HTTP client using Armadito protocol.

=head1 DESCRIPTION

This is the class used by agent to communicate with armadito plugin in GLPI.

=head1 METHODS

=head2 send(%params)

Send a request to the armadito plugin in GLPI.

The following parameters are allowed, as keys of the %params
hash:

=over

=item I<url>

the url to send the message to (mandatory)

=item I<message>

the message to send (mandatory)

=back

This method returns an unknown instance.
