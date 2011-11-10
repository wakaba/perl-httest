package test::HTTest::Mock::Test::Echo;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Web::UserAgent::Functions qw/http_get/;
use HTTest::Mock;
use HTTest::Mock::Test::Echo;
use Encode;

sub _ascii : Test(3) {
    my ($req, $res) = http_get
        url => q<http://echo.test/body?abc>;

    is $res->code, 200;
    is $res->content_type, 'text/html; charset=utf-8';
    is $res->content, q[abc];
}

sub _ascii_escaped : Test(3) {
    my ($req, $res) = http_get
        url => q<http://echo.test/body?abc%20xyz%2b%2B+>;

    is $res->code, 200;
    is $res->content_type, 'text/html; charset=utf-8';
    is $res->content, q[abc xyz+++];
}

sub _latin1 : Test(3) {
    my ($req, $res) = http_get
        url => qq<http://echo.test/body?abc\xA4\xC4>;

    is $res->code, 200;
    is $res->content_type, 'text/html; charset=utf-8';
    is $res->content, qq[abc\xA4\xC4];
}

sub _utf8 : Test(3) {
    my ($req, $res) = http_get
        url => qq<http://echo.test/body?abc\x{4e00}\xA1>;

    is $res->code, 200;
    is $res->content_type, 'text/html; charset=utf-8';
    is $res->content, encode 'utf8', qq[abc\x{4e00}\xA1];
}

sub _utf8_escaped : Test(3) {
    my ($req, $res) = http_get
        url => qq<http://echo.test/body?abc\x{4e00}%21>;

    is $res->code, 200;
    is $res->content_type, 'text/html; charset=utf-8';
    is $res->content, encode 'utf8', qq[abc\x{4e00}!];
}

__PACKAGE__->runtests;

1;
