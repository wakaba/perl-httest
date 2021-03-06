package test::HTTest::Twitter;
use strict;
use warnings;
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*/lib');
use base qw(Test::Class);
use Test::MoreMore;
use HTTest::Twitter;

HTTest::Twitter->register_account_for_test(
    access_token => 'TOKEN',
    access_token_secret => 'TOKEN_SECRET',
    account_id => 12345,
    user_name => 'testtwitter1',
    mail_addr => q<testtwitter1@test>,
    password => 'testtwitter1password',
);

sub _account_ok_user : Test(1) {
    my $twitter = HTTest::Twitter->new;
    my @result = $twitter->xauth(q<testtwitter1>, q<testtwitter1password>);
    eq_or_diff \@result, [qw(TOKEN TOKEN_SECRET 12345 testtwitter1)];
}

sub _account_ok_mail : Test(1) {
    my $twitter = HTTest::Twitter->new;
    my @result = $twitter->xauth(q<testtwitter1@test>, q<testtwitter1password>);
    eq_or_diff \@result, [qw(TOKEN TOKEN_SECRET 12345 testtwitter1)];
}

sub _account_wrong_password_user : Test(1) {
    my $twitter = HTTest::Twitter->new;
    eval {
        $twitter->xauth(q<testtwitter1>, q<password>);
        ng 1;
    } or do {
        like $@, qr<401>;
    };
}

sub _account_wrong_password_mail : Test(1) {
    my $twitter = HTTest::Twitter->new;
    eval {
        $twitter->xauth(q<testtwitter1@test>, q<password>);
        ng 1;
    } or do {
        like $@, qr<401>;
    };
}

sub _account_not_found : Test(1) {
    my $twitter = HTTest::Twitter->new;
    eval {
        $twitter->xauth(q<twitteraccountnotfound>, q<password>);
        ng 1;
    } or do {
        like $@, qr<401>;
    };
}

sub _followers : Test(1) {
    my $twitter = HTTest::Twitter->new;
    dies_ok { $twitter->followers }
}

sub _following : Test(1) {
    my $twitter = HTTest::Twitter->new;
    dies_ok { $twitter->following }
}

sub _following_ids : Test(6) {
    my $twitter = HTTest::Twitter->new;
    my $return = $twitter->following_ids;
    is ref $return, 'HASH';
    is $return->{previous_cursor}, 0;
    is $return->{previous_cursor_str}, '0';
    is $return->{next_cursor}, 0;
    is $return->{next_cursor_str}, '0';
    is_deeply $return->{ids}, [143206502, 143201767, 777925];
}

sub _followers_ids : Test(6) {
    my $twitter = HTTest::Twitter->new;
    my $return = $twitter->followers_ids;
    is ref $return, 'HASH';
    is $return->{previous_cursor}, 0;
    is $return->{previous_cursor_str}, '0';
    is $return->{next_cursor}, 0;
    is $return->{next_cursor_str}, '0';
    is_deeply $return->{ids}, [570143878, 569940541, 317955476];
}

sub _update : Test(1) {
    $HTTest::Twitter::LastUpdate = {};
    my $twitter = HTTest::Twitter->new(
        consumer_key => 'abc',
        consumer_secret => 'def',
        access_token => 'xyz',
        access_token_secret => 'stu',
    );
    $twitter->update({status => "\x{5000}\x{6000}", lat => 10, long => 3});
    eq_or_diff $HTTest::Twitter::LastUpdate, {
        consumer_key => 'abc',
        consumer_secret => 'def',
        access_token => 'xyz',
        access_token_secret => 'stu',
        args => {status => "\x{5000}\x{6000}", lat => 10, long => 3},
    };
}

__PACKAGE__->runtests;

1;
