package test::HTTest::Response;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use HTTest::Response;
use Encode;

sub _isa : Test(6) {
    for (
        'HTTest::Response',
        'Test::MoreMore::Mock',
        'HTTP::Response',
        'HASH',
    ) {
        my $res = HTTest::Response->new;
        ok $res->isa($_);
    }

    for (
        'HTTP::Request',
        'Ridge::Response',
    ) {
        my $res = HTTest::Response->new;
        ng $res->isa($_);
    }
}

sub _is_ : Test(88) {
    for (
        [100, 1, 0, 0, 0],
        [101, 1, 0, 0, 0],
        [200, 0, 1, 0, 0],
        [201, 0, 1, 0, 0],
        [203, 0, 1, 0, 0],
        [204, 0, 1, 0, 0],
        [205, 0, 1, 0, 0],
        [206, 0, 1, 0, 0],
        [300, 0, 0, 1, 0],
        [301, 0, 0, 1, 0],
        [302, 0, 0, 1, 0],
        [303, 0, 0, 1, 0],
        [304, 0, 0, 1, 0],
        [307, 0, 0, 1, 0],
        [400, 0, 0, 0, 1],
        [401, 0, 0, 0, 1],
        [403, 0, 0, 0, 1],
        [404, 0, 0, 0, 1],
        [500, 0, 0, 0, 1],
        [501, 0, 0, 0, 1],
        [502, 0, 0, 0, 1],
        [503, 0, 0, 0, 1],
    ) {
        my $res = HTTest::Response->new;
        $res->code($_->[0]);
        is_bool $res->is_info, $_->[1];
        is_bool $res->is_success, $_->[2];
        is_bool $res->is_redirect, $_->[3];
        is_bool $res->is_error, $_->[4];
    }
}

sub _new : Test(14) {
    my $res;

    $res = HTTest::Response->new(200);
    isa_ok $res, 'HTTest::Response';
    is $res->code, 200;

    $res = HTTest::Response->new(code => 200);
    isa_ok $res, 'HTTest::Response';
    is $res->code, 200;

    $res = HTTest::Response->new(200, 'OK');
    isa_ok $res, 'HTTest::Response';
    is $res->code, 200;
    is $res->message, 'OK';

    $res = HTTest::Response->new(code => 200, message => 'OK');
    isa_ok $res, 'HTTest::Response';
    is $res->code, 200;
    is $res->message, 'OK';

    $res = HTTest::Response->new(200, 'OK', [], 'hello');
    isa_ok $res, 'HTTest::Response';
    is $res->code, 200;
    is $res->message, 'OK';
    is $res->content, 'hello';
}

sub _content_type : Test(6) {
    my $res = HTTest::Response->new;
    is $res->content_type, undef;
    
    $res->content_type('text/plain');
    is $res->content_type, 'text/plain';
    
    $res->content_type('TExt/PLAIN; charset=utf-8');
    is $res->content_type, 'TExt/PLAIN; charset=utf-8';
    
    $res->content_type('application/xml');
    is $res->content_type, 'application/xml';
    
    is $res->header('content-type'), 'application/xml';
    is $res->header('Content-Type'), 'application/xml';
}

sub _header : Test(4) {
    my $res = HTTest::Response->new;
    
    is $res->header('X-abc'), undef;
    
    $res->header('Content-Type' => 'text/plain');
    is $res->header('Content-Type'), 'text/plain';
    is $res->header('content-type'), 'text/plain';
    
    $res->header('x-foo' => 1);
    is $res->header('x-foo'), 1;
}

sub _server_not_found : Test(2) {
    my $res = HTTest::Response->new;
    $res->server_not_found;
    is $res->code, 500;
    ok $res->header('Client-Warning');
}

sub _charset_none : Test(1) {
    my $res = HTTest::Response->new;
    $res->header('Content-Type' => 'text/plain');
    is $res->charset, undef;
}

sub _charset_yes : Test(1) {
    my $res = HTTest::Response->new;
    $res->header('Content-Type' => 'text/plain; charset=ISO-2022-jp');
    is $res->charset, 'ISO-2022-jp';
}

sub _encoder : Test(1) {
    my $res = HTTest::Response->new;
    $res->header('Content-Type' => 'text/plain; charset=euc-jp');
    isa_ok $res->encoder, 'Encode::XS';
}

sub _encoding : Test(1) {
    my $res = HTTest::Response->new;
    $res->header('Content-Type' => 'text/plain; charset=euc-JP');
    is $res->encoding, 'euc-jp';
}

sub _decoded_content_ascii : Test(1) {
    my $res = HTTest::Response->new;
    $res->content_type('text/plain; charset=us-ascii');
    $res->content('abcdef');
    is $res->decoded_content, 'abcdef';
}

sub _decoded_content_utf8 : Test(1) {
    my $res = HTTest::Response->new;
    $res->content_type('text/plain; charset=utf-8');
    $res->content(encode 'utf8', "\x{4e00}ab\x{4e01}cdef");
    is $res->decoded_content, "\x{4e00}ab\x{4e01}cdef";
}

sub _decoded_content_error : Test(1) {
    my $res = HTTest::Response->new;
    $res->content_type('text/plain');
    $res->content('abcdef');
    dies_ok { $res->decoded_content };
}

sub _decoded_content_noerror : Test(1) {
    my $res = HTTest::Response->new;
    $res->content_type('text/plain');
    $res->content('abcdef');
    is $res->decoded_content(raise_error => 0), undef;
}

sub _decoded_content_not_text : Test(1) {
    my $res = HTTest::Response->new;
    $res->content_type('image/jpg');
    $res->content('abcdef');
    is $res->decoded_content, 'abcdef';
}

__PACKAGE__->runtests;

1;
