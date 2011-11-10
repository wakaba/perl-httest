package test::HTTest::Mock;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Web::UserAgent::Functions qw/http_get http_post_data/;
use HTTest::Mock;
use HTTest::Mock::Server;

sub _not_found : Test(3) {
    my ($req, $res) = http_get
        url => q<http://test/path>;
    isa_ok $res, 'HTTest::Response';
    is $res->code, 404;
    is $res->message, 'Not found';
}

sub _add_handler : Test(4) {
    HTTest::Mock::Server->add_handler(qr[//test\.add_handler/] => sub {
        my ($server, $req, $res) = @_;
        $res->content_type('text/html');
        $res->content('abcdefg');
    });
    my ($req, $res) = http_get
        url => q<http://test.add_handler/path>;
    is $res->code, 200;
    is $res->message, 'OK';
    is $res->content_type, 'text/html';
    is $res->content, 'abcdefg';
}

sub _add_handlers : Test(11) {
    HTTest::Mock::Server->add_handler(qr[//test\.add_handlers/1] => sub {
        my ($server, $req, $res) = @_;
        $res->content_type('text/html');
        $res->content('abcdefg');
    });
    HTTest::Mock::Server->add_handler(qr[//test\.add_handlers/2] => sub {
        my ($server, $req, $res) = @_;
        $res->content_type('text/plain');
        $res->content(123456);
    });

    my ($req1, $res1) = http_get
        url => q<http://test.add_handlers/path>;
    is $res1->code, 404;
    isnt $res1->content, 'abcdefg';
    isnt $res1->content, 123456;
    
    my ($req2, $res2) = http_get
        url => q<http://test.add_handlers/1>;
    is $res2->code, 200;
    is $res2->message, 'OK';
    is $res2->content_type, 'text/html';
    is $res2->content, 'abcdefg';

    my ($req3, $res3) = http_get
        url => q<http://test.add_handlers/2>;
    is $res3->code, 200;
    is $res3->message, 'OK';
    is $res3->content_type, 'text/plain';
    is $res3->content, '123456';
}

sub _add_handler_match : Test(4) {
    HTTest::Mock::Server->add_handler(qr[//match/(.*)] => sub {
        my ($server, $req, $res) = @_;
        $res->content_type('text/html');
        $res->content('abcdefg' . $1);
    });
    my ($req, $res) = http_get
        url => q<http://match/path>;
    is $res->code, 200;
    is $res->message, 'OK';
    is $res->content_type, 'text/html';
    is $res->content, 'abcdefgpath';
}

sub _json : Test(4) {
    HTTest::Mock::Server->add_handler(qr[//json/(.*)] => sub {
        my ($server, $req, $res) = @_;
        $res->set_json({value => $1});
    });
    my ($req, $res) = http_get
        url => q<http://json/abcdefg>;
    is $res->code, 200;
    is $res->message, 'OK';
    is $res->content_type, 'application/json';
    is $res->content, '{
   "value" : "abcdefg"
}';
}

sub _response_header : Test(2) {
    HTTest::Mock::Server->add_handler(qr[//response_header/(.*)] => sub {
        my ($server, $req, $res) = @_;
        $res->header(a => 'bcd', x => '123');
        $res->code(200);
    });
    my ($req, $res) = http_get
        url => q<http://response_header/abcdefg>;
    is $res->header('a'), 'bcd';
    is $res->header('x'), '123';
}

sub _status_line : Test(1) {
    HTTest::Mock::Server->add_handler(qr[//status_line/(.*)] => sub {
        my ($server, $req, $res) = @_;
        $res->code(403);
        $res->message('You are not allowed to do it');
    });
    my ($req, $res) = http_get
        url => q<http://status_line/abcdefg>;
    is $res->status_line, '403 You are not allowed to do it';
}

sub _get_get_params_from_req_as_hash_encoding : Test(1) {
    HTTest::Mock::Server->add_handler(qr[//getparamencoded/sjis] => sub {
        my ($server, $req, $res) = @_;
        my $params = $server->get_get_params_from_req_as_hash($req, encoding => 'sjis');
        is $params->{foo}, "\x{3000}";
    });
    my ($req, $res) = http_get
        url => q<http://getparamencoded/sjis?foo=%81%40>;
}

sub _get_post_params_from_req_as_hash_encoding : Test(1) {
    HTTest::Mock::Server->add_handler(qr[//postparamencoded/sjis] => sub {
        my ($server, $req, $res) = @_;
        my $params = $server->get_post_params_from_req_as_hash($req, encoding => 'sjis');
        is $params->{foo}, "\x{3000}";
    });
    my ($req, $res) = http_post_data
        url => q<http://postparamencoded/sjis>,
        content_type => 'application/x-www-form-urlencoded',
        content => 'foo=%81%40';
}

sub _response_class : Test(4) {
    my ($req1, $res1) = http_get url => q<http://example.org/1st>;
    isa_ok $res1, 'HTTest::Response';

    HTTest::Mock::Server->response_class('HTTP::Response');
    my ($req2, $res2) = http_get url => q<http://example.org/2nd>;
    isa_ok $res2, 'HTTP::Response';
    ng $res2->isa('HTTest::Response');

    HTTest::Mock::Server->response_class('HTTest::Response');
    my ($req3, $res3) = http_get url => q<http://example.org/3rd>;
    isa_ok $res3, 'HTTest::Response';
}

__PACKAGE__->runtests;

1;
