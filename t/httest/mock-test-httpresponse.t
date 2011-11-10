package test::HTTest::Mock::Test::HTTPResponse;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Web::UserAgent::Functions qw/http_get/;
use HTTest::Mock;
use HTTest::Mock::Test::HTTPResponse;
use Encode;

sub _code : Test(14) {
    for my $code (
        100,
        200,
        205,
        302,
        404,
        500,
        601,
    ) {
        {
            my ($req, $res) = http_get
                url => qq<http://http-response.test/$code>;
            
            is $res->code, $code;
        }
        
        {
            my ($req, $res) = http_get
                url => qq<http://http-response.test/$code>;
            
            is $res->code, $code;
        }
    }
}

sub _type : Test(12) {
    for (
        [txt => 'plain-text', 'text/plain'],
        [html => 'HTML'],
        [xhtml => 'xhtml'],
        [atom => 'Atom'],
        [rss => 'RSS'],
        [xml => 'XML'],
    ) {
        my ($req, $res) = http_get
            url => qq[http://http-response.test/200.$_->[0]];
        
        like $res->content_type, $_->[2] ? qr[$_->[2]] : qr[$_->[0]];
        like $res->content, qr[$_->[1]];
    }
}

sub _charset : Test(8) {
    for (
        [jis => 'iso-2022-jp'],
        [euc => 'euc-jp'],
        [sjis => 'shift_jis'],
        [utf8 => 'utf-8']
   ) {
        my ($req, $res) = http_get
            url => qq[http://http-response.test/200.html.$_->[0]];

        like $res->content_type, qr[$_->[1]];
        my $content = decode $_->[1], $res->content;
        use utf8;
        like $content, qr[これは];
    }
}

__PACKAGE__->runtests;

1;
