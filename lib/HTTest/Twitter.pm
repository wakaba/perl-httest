package HTTest::Twitter;
use strict;
use warnings;
use base qw(Test::MoreMore::Mock);
use List::Rubyish;
use Carp;

# Net::Twitter::Lite と (ある程度) 互換なテスト用モジュールです。

our $TwitterAccounts = List::Rubyish->new;

sub register_account_for_test {
    my ($class, %args) = @_;

    my $current = $TwitterAccounts->find(sub { $_->{user_name} eq $args{user_name} });
    if ($current) {
        %$current = %args;
    } else {
        $TwitterAccounts->push(\%args);
    }
}

sub xauth {
    my ($self, $username, $password) = @_;

    my $account = $TwitterAccounts->find(sub {
        ($_->{user_name} eq $username or $_->{mail_addr} eq $username) and
        $_->{password} eq $password
    });
    die "401\n" unless $account;

    return (
        $account->{access_token},
        $account->{access_token_secret},
        $account->{account_id},
        $account->{user_name},
    );
}

sub followers {
    my ($self, $arg) = @_;

    croak 'twitter followers api was deprecated';

    require JSON::XS;
    require Path::Class;
    my $file = Path::Class::file(__FILE__)->dir->parent->parent->file('data/followers.dat')->stringify;
    my $users =  do $file;
    if (($arg || {})->{cursor}) {
        return +{
            next_cursor     => 0,
            previous_cursor => 0,
            users           => $users,
        };
    } else {
        return $users;
    }
}

sub following {
    my ($self, $arg) = @_;

    croak 'twitter friends(following) api was deprecated';
    require JSON::XS;
    require Path::Class;
    my $file = Path::Class::file(__FILE__)->dir->parent->parent->file('data/following.dat')->stringify;
    my $users =  do $file;
    if (($arg || {})->{cursor}) {
        return +{
            next_cursor     => 0,
            previous_cursor => 0,
            users => $users,
        };
    } else {
        return $users;
    }
}

sub following_ids {
    my ($self, $arg) = @_;

    require Path::Class;
    my $file = Path::Class::file(__FILE__)->dir->parent->parent->file('data/following-ids.dat')->stringify;
    my $ids = do $file;
    return +{
        previous_cursor     => 0,
        previous_cursor_str => '0',
        ids             => $ids,
        next_cursor     => 0,
        next_cursor_str => '0',
    };
}

sub followers_ids {
    my ($self, $arg) = @_;

    require Path::Class;
    my $file = Path::Class::file(__FILE__)->dir->parent->parent->file('data/followers-ids.dat')->stringify;
    my $ids = do $file;
    return +{
        previous_cursor     => 0,
        previous_cursor_str => '0',
        ids             => $ids,
        next_cursor     => 0,
        next_cursor_str => '0',
    };
}

our $LastUpdate;
our $UpdateReturn;

sub update {
    my ($self, $args) = @_;

    $LastUpdate = {
        consumer_key => scalar $self->consumer_key,
        consumer_secret => scalar $self->consumer_secret,
        access_token => scalar $self->access_token,
        access_token_secret => scalar $self->access_token_secret,
        args => $args,
    };

    return $UpdateReturn;
}

our $FriendsTimeline ||= [];

sub friends_timeline {
    my $self = shift;
    return $FriendsTimeline;
}

1;
