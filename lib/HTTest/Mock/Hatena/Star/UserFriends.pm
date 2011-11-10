package HTTest::Mock::Hatena::Star::UserFriends;
use strict;
use warnings;
our $VERSION = '1.0';
use HTTest::Mock::Server;

our $Friends = {
    hatenatestuser1 => [
        {name => 'hatenatestuser2'},
    ],
};

HTTest::Mock::Server->add_handler(qr[//s.hatena.ne.jp/([^/]+)/friends\.json] => sub {
    my ($server, $req, $res) = @_;
    my $user = $1;
    $user =~ s/%40/\@/;
    if ($Friends->{$user}) {
        $res->set_json({
            friends => $Friends->{$user},
        });
    } else {
        $res->code(404);
    }
});

1;
