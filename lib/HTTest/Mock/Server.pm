package HTTest::Mock::Server;
use strict;
use warnings;
our $VERSION = '2.0';
use HTTest::Response;
use List::Rubyish;
use Encode;

our $DEBUG ||= $ENV{HTTEST_DEBUG};

our $Handlers = List::Rubyish->new;

our $ResponseClass = 'HTTest::Response';

# backcompat
sub response_class {
    if (@_ > 1) {
        $ResponseClass = $_[1];
    }
    return $ResponseClass;
}

sub request {
    my ($class, $req) = @_;

    my $res_class = __PACKAGE__->response_class;
    eval qq{ require $res_class } or die $@;
    my $res = $res_class->new(200, 'OK');
    my $url = $req->uri;

    $res->request($req);

    my $code = sub {
        my ($server, $req, $res) = @_;
        $res->code(404);
        $res->message('Not found');
    };

    if ($DEBUG) {
        my @header;
        $req->scan(sub {
            push @header, $_[0] . ': ' . $_[1];
        });
        print STDERR "========== REQUEST ==========\n";
        print STDERR $req->method, ' ', $req->uri, "\n";
        print STDERR $_, "\n" for @header;
        print STDERR "\n";
        print STDERR $req->content if $DEBUG >= 2;
        print STDERR "======== HTTest::Mock =======\n";
    }

    for my $handler (@{$Handlers}) {
        if ($url =~ /$handler->{pattern}/) {
            local $@;
            eval {
                $handler->{code}->($class, $req, $res);
                1;
            } or warn $@;
            undef $code;
            last;
        }
    }
    $code->($class, $req, $res) if $code;

    if ($DEBUG) {
        print STDERR "========== RESPONSE =========\n";
        print STDERR $res->header_as_string;
        print STDERR "\n";
        print STDERR $res->content, "\n" if $DEBUG >= 2;
        print STDERR "======== HTTest::Mock =======\n";
    }

    return $res;
}

sub add_handler {
    my ($class, $pattern, $code) = @_;
    
    $Handlers->push({
        pattern => $pattern,
        code => $code,
    });
}

sub get_get_params_from_req_as_hash {
    my ($class, $req, %args) = @_;
    my $url = $req->url;
    $url =~ s/\#.*//s;
    return {} unless $url =~ /\?/;
    $url =~ s/^.*\?//s;
    my $encoding = $args{encoding} || 'utf8';
    return +{map { tr/+/ /; s/%([0-9A-Fa-f]{2})/pack 'C', hex $1/ge; decode $encoding, $_ }
             map { split /=/, $_, 2 }
             split /[&;]/, $url};
}

sub get_post_params_from_req_as_hash {
    my ($class, $req, %args) = @_;
    my $encoding = $args{encoding} || 'utf8';
    return +{map { tr/+/ /; s/%([0-9A-Fa-f]{2})/pack 'C', hex $1/ge; decode $encoding, $_ }
             map { split /=/, $_, 2 }
             split /[&;]/, $req->content};
}

sub get_post_params_from_req_as_array {
    my ($class, $req, %args) = @_;
    my $encoding = $args{encoding} || 'utf8';
    return +[map { tr/+/ /; s/%([0-9A-Fa-f]{2})/pack 'C', hex $1/ge; decode $encoding, $_ }
             map { split /=/, $_, 2 }
             split /[&;]/, $req->content];
}

1;
