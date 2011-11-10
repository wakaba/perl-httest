package test::HTTest::Mock::Hatena::Star::UserFriends;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*', 'lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Web::UserAgent::Functions qw/http_get/;
use JSON::Functions::XS qw(json_bytes2perl);
use HTTest::Mock;
use HTTest::Mock::Hatena::Star::UserFriends;

sub _not_found : Test(1) {
    my ($req, $res) = http_get
        url => q<http://s.hatena.ne.jp/hatenanotfounduser/friends.json>;
    is $res->code, 404;
}

sub _empty : Test(2) {
    $HTTest::Mock::Hatena::Star::UserFriends::Friends->{hatenaemptyuser} = [];
    my ($req, $res) = http_get
        url => q<http://s.hatena.ne.jp/hatenaemptyuser/friends.json>;
    is $res->code, 200;
    my $json = json_bytes2perl $res->content;
    eq_or_diff $json, {friends => []};
}

sub _empty_at : Test(4) {
    $HTTest::Mock::Hatena::Star::UserFriends::Friends->{'hatenaemptyuser@foo'} = [];
    {
        my ($req, $res) = http_get
            url => q<http://s.hatena.ne.jp/hatenaemptyuser@foo/friends.json>;
        is $res->code, 200;
        my $json = json_bytes2perl $res->content;
        eq_or_diff $json, {friends => []};
    }
    {
        my ($req, $res) = http_get
            url => q<http://s.hatena.ne.jp/hatenaemptyuser%40foo/friends.json>;
        is $res->code, 200;
        my $json = json_bytes2perl $res->content;
        eq_or_diff $json, {friends => []};
    }
}

sub _nonempty : Test(2) {
    $HTTest::Mock::Hatena::Star::UserFriends::Friends->{'hatenanon-emptyuser'} = [
        {name => 'hatenatestuser1'},
        {name => 'hatenatestuser2@baz'},
    ];
    my ($req, $res) = http_get
        url => q<http://s.hatena.ne.jp/hatenanon-emptyuser/friends.json>;
    is $res->code, 200;
    my $json = json_bytes2perl $res->content;
    eq_or_diff $json, {friends => [
        {name => 'hatenatestuser1'},
        {name => 'hatenatestuser2@baz'},
    ]};
}

sub _nonempty_at : Test(4) {
    $HTTest::Mock::Hatena::Star::UserFriends::Friends->{'hatenanon-emptyuser@foo'} = [
        {name => 'hatenatestuser1'},
        {name => 'hatenatestuser2@baz'},
    ];
    {
        my ($req, $res) = http_get
            url => q<http://s.hatena.ne.jp/hatenanon-emptyuser@foo/friends.json>;
        is $res->code, 200;
        my $json = json_bytes2perl $res->content;
        eq_or_diff $json, {friends => [
            {name => 'hatenatestuser1'},
            {name => 'hatenatestuser2@baz'},
        ]};
    }
    {
        my ($req, $res) = http_get
            url => q<http://s.hatena.ne.jp/hatenanon-emptyuser%40foo/friends.json>;
        is $res->code, 200;
        my $json = json_bytes2perl $res->content;
        eq_or_diff $json, {friends => [
            {name => 'hatenatestuser1'},
            {name => 'hatenatestuser2@baz'},
        ]};
    }
}

__PACKAGE__->runtests;

1;
