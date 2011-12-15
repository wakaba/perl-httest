package test::HTTest::Mock::Microsoft::Translator;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;

sub _use_ok : Test(1) {
    use_ok 'HTTest::Mock::Microsoft::Translator';
}

__PACKAGE__->runtests;

1;
