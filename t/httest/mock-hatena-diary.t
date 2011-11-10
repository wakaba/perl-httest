package test::HTTest::Mock::Hatena::Diary;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Web::UserAgent::Functions qw/http_get/;
use HTTest::Mock;
use HTTest::Mock::Hatena::Diary;

sub _keywordrss : Test(2) {
    my ($req, $res) = http_get
        url => q<http://d.hatena.ne.jp/keyword?word=%E6%9D%B1%E4%BA%AC&mode=rss&ie=utf8>;

    is $res->code, 200;
    like $res->content, qr<blockquote>;
}

sub _keywordlog : Test(2) {
    my ($req, $res) = http_get
        url => q<http://d.hatena.ne.jp/keywordlog?klid=1012699>;

    is $res->code, 200;
    like $res->content, qr<Emacs>;
}

sub _keywordeditemacs : Test(2) {
    my ($req, $res) = http_get
        url => q<http://d.hatena.ne.jp/keyword/Emacs?kid=7383&mode=edit>;

    is $res->code, 200;
    like $res->content, qr<Emacs>;
}

__PACKAGE__->runtests;

1;
