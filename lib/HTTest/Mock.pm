package HTTest::Mock;
use strict;
use warnings;
our $VERSION = '1.0';
use HTTest::Mock::Server;
use LWP::UserAgent;
$LWP::Simple::FULL_LWP = 1; # For older versions of LWP::Simple

our $ORIGINAL_LWP_UserAgent_new = \&LWP::UserAgent::new;
our $ORIGINAL_LWP_UserAgent_max_redirect = \&LWP::UserAgent::max_redirect;
our $ORIGINAL_LWP_UserAgent_simple_request = \&LWP::UserAgent::simple_request;

sub import {
    no warnings 'redefine';
    *LWP::UserAgent::new = sub {
        my $self = $ORIGINAL_LWP_UserAgent_new->(@_);
        $self->{max_redirect} = 0;
        $self;
    };
    *LWP::UserAgent::max_redirect = sub { };
    *LWP::UserAgent::simple_request = sub {
        my ($self, $req) = @_;
        return HTTest::Mock::Server->request($req);
    };
}

sub unimport {
    no warnings 'redefine';
    *LWP::UserAgent::new = $ORIGINAL_LWP_UserAgent_new;
    *LWP::UserAgent::max_redirect = $ORIGINAL_LWP_UserAgent_max_redirect;
    *LWP::UserAgent::simple_request = $ORIGINAL_LWP_UserAgent_simple_request;
}

1;
