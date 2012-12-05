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
        my ($self, $req, $arg) = @_;
        my $res = HTTest::Mock::Server->request($req);
        # If $arg is string, response content is saved to a file
        # whose path is $arg.
        # (In case that a filename is provided with the :content_file option
        # on LWP::UserAgent#get method, the filename is passed to
        # LWP::UserAgent::simple_request method as argument $arg.)
        _proccess_response($res, $arg);
        return $res;
    };
}

# Write response content into file whose path is $arg
# this process is based on a part of LWP::Protocol::collect method
# (, which is called from LWP::Protocol::http::request method)
sub _proccess_response {
    my ( $response, $arg ) = @_;
    eval {
        local $\; # protect the print below from surprises
        if (!defined($arg) || !$response->is_success) {
            # do nothing
        }
        elsif (!ref($arg) && length($arg)) {
            my $content = $response->content;
            $response->content('');
            open(my $fh, ">", $arg) or die "Can't write to '$arg': $!";
            binmode($fh);
            print $fh $content or die "Can't write to '$arg': $!";
            close($fh) or die "Can't write to '$arg': $!";
            undef($fh);
        }
    };
    if (my $err = $@) {
        chomp($err);
        $response->push_header('X-Died' => $err);
        $response->push_header("Client-Aborted", "die");
    }
}

sub unimport {
    no warnings 'redefine';
    *LWP::UserAgent::new = $ORIGINAL_LWP_UserAgent_new;
    *LWP::UserAgent::max_redirect = $ORIGINAL_LWP_UserAgent_max_redirect;
    *LWP::UserAgent::simple_request = $ORIGINAL_LWP_UserAgent_simple_request;
}

1;
