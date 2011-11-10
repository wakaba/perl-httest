package test::HTTest::Hatena::Keyword;
use strict;
use warnings;
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->subdir('lib');
use base qw(Test::Class);
use Test::MoreMore;
use HTTest::Hatena::Keyword;

sub _extract_0 : Test(1) {
    use utf8;
    my $keywords = HTTest::Hatena::Keyword->extract('not-found');
    eq_or_diff $keywords, [];
}

sub _extract_0_array : Test(1) {
    use utf8;
    my @keyword = HTTest::Hatena::Keyword->extract('not-found');
    eq_or_diff \@keyword, [];
}

sub _extract_1 : Test(1) {
    use utf8;
    my $keywords = HTTest::Hatena::Keyword->extract('はてな');
    eq_or_diff $keywords, ['はてな'];
}

sub _extract_1_array : Test(1) {
    use utf8;
    my @keyword = HTTest::Hatena::Keyword->extract('はてな');
    eq_or_diff \@keyword, ['はてな'];
}

sub _extract_2 : Test(1) {
    use utf8;
    my $keywords = HTTest::Hatena::Keyword->extract('はてな naoya');
    eq_or_diff $keywords, ['はてな', 'naoya'];
}

sub _extract_2_array : Test(1) {
    use utf8;
    my @keyword = HTTest::Hatena::Keyword->extract('はてな naoya');
    eq_or_diff \@keyword, ['はてな', 'naoya'];
}

sub _extract_3 : Test(1) {
    use utf8;
    my $keywords = HTTest::Hatena::Keyword->extract('はてなきせかいへ');
    eq_or_diff $keywords, ['はてな'];
}

sub _extract_3_array : Test(1) {
    use utf8;
    my @keyword = HTTest::Hatena::Keyword->extract('はてなきせかいへ');
    eq_or_diff \@keyword, ['はてな'];
}

__PACKAGE__->runtests;

1;
