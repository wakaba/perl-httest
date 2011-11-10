package HTTest::Mock::Hatena::Fotolife;
use strict;
use warnings;
use HTTest::Mock;
use Exporter::Lite;

our $FUserStatus = {};
our $PostRequested = 0;
our $PostGetParams = {};
our $PostBody = undef;

sub reset_post () {
    $PostRequested = 0;
    $PostGetParams = {};
    $PostBody = undef;
}

our @EXPORT = qw(
    $FUserStatus
    $PostRequested
    $PostGetParams
    $PostBody
    reset_post
);

HTTest::Mock::Server->add_handler(qr<^http://f.hatena.ne.jp/atom/post>, sub {
    my ($class, $req, $res) = @_;
    $PostRequested++;
    $PostGetParams = $class->get_get_params_from_req_as_hash($req);
    $PostBody = $req->content;

    if ($FUserStatus->{full}) {
        $res->code(500);
        $res->message('Internal Server Error');
        $res->header(Status => '500 your fotolife disk is full.');
    } else {
        $res->code(201);
        $res->message('Created');
        $res->header('Content-Type' => 'application/x.atom+xml');
        $res->header('Location' => 'http://f.hatena.ne.jp/atom/edit/20000101020304');
        $res->content(q[<?xml version="1.0" encoding="utf-8"?>

<entry xmlns="http://purl.org/atom/ns#" xmlns:hatena="http://www.hatena.ne.jp/info/xmlns#">
  <title>Sample</title>
  <link rel="alternate" type="text/html" href="http://f.hatena.ne.jp/naoya/20000101020304"/>
  <link rel="service.edit" type="application/x.atom+xml" href="http://f.hatena.ne.jp/atom/edit/20000101020304" title="Sample"/>
  <issued>2005-01-14T17:01:29+09:00</issued>
  <author>
    <name>naoya</name>
  </author>
  <generator url="http://f.hatena.ne.jp/" version="1.0">Hatena::Fotolife</generator>
  <dc:subject xmlns:dc="http://purl.org/dc/elements/1.1/">YYYYYY</dc:subjetct>
  <id>tag:hatena.ne.jp,2005:fotolife-naoya-20000101020304</id>
  <hatena:imageurl>http://f.hatena.ne.jp/images/fotolife/n/naoya/XXXXXXXX/20000101020304.jpg</hatena:imageurl>
  <hatena:imageurlsmall>http://f.hatena.ne.jp/images/fotolife/n/naoya/XXXXXXXX/20000101020304_m.gif</hatena:imageurlsmall>
  <hatena:syntax>f:id:naoya:20000101020304:image</hatena:syntax>
</entry>]);
    }
});

1;
