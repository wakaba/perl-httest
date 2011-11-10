package HTTest::Mock::Test::Echo;
use strict;
use warnings;
our $VERSION = '1.0';
use HTTest::Mock::Server;
use Encode;

HTTest::Mock::Server->add_handler(qr<^https?://echo.test/body\?(.*)>s, sub {
    my ($class, $req, $res) = @_;

    my $body = encode 'utf8', $1;
    $body =~ s/%([0-9A-Fa-f]{2})/pack 'C', hex $1/ge;

    $res->code(200);
    $res->content_type('text/html; charset=utf-8');
    $res->content($body);
});

1;
