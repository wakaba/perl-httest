package HTTest::Mock::Test::HTTPResponse;
use strict;
use warnings;
our $VERSION = '1.0';
use HTTest::Mock::Server;
use Path::Class;
use Encode;

my $data_d = file(__FILE__)->dir->subdir('HTTPResponse');

HTTest::Mock::Server->add_handler(qr<^https?://http-response.test/([0-9]+)(?:\.(x?html|atom|rss|txt|xml))?(?:\.(s?jis|euc|utf8))?$>, sub {
    my ($class, $req, $res) = @_;

    my $code = $1;
    my $type = $2 || 'html';
    my $charset = $3 || 'utf8';
    my $type_long = {
        html => 'text/html',
        xhtml => 'application/xhtml+xml',
        xml => 'application/xml',
        atom => 'application/atom+xml',
        rss => 'application/rss+xml',
        txt => 'text/plain',
    }->{$type} || die;
    my $charset_long = {
        jis => 'iso-2022-jp',
        euc => 'euc-jp',
        sjis => 'shift_jis',
        utf8 => 'utf-8',
    }->{$charset} || die;

    my $content = encode $charset_long, decode 'utf8', $data_d->file('test.' . $type)->slurp;
    
    $res->code($code);
    $res->content_type("$type_long; charset=$charset_long");
    $res->content($content);
});

1;
