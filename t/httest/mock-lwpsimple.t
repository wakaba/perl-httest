package test::HTTest::Mock::LWPSimple;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use HTTest::Mock;
use HTTest::Mock::Server;
use LWP::Simple;

sub _add_handler : Test(1) {
    HTTest::Mock::Server->add_handler(qr[//test\.add_handler/] => sub {
        my ($server, $req, $res) = @_;
        $res->content_type('text/html; charset=utf-8');
        $res->content('abcdefg');
    });
    my $return = LWP::Simple::get(q<http://test.add_handler/path>);
    is $return, 'abcdefg';
}

__PACKAGE__->runtests;

1;
