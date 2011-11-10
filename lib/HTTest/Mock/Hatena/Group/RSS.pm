package HTTest::Mock::Hatena::Group::RSS;
use strict;
use warnings;
use HTTest::Mock;
use Path::Class;

my $hatena_hatena_rss_f = file(__FILE__)->dir->file('hatenahatenarss.xml');

HTTest::Mock::Server->add_handler(qr<^http://hatena.g.hatena.ne.jp/hatena/rss$>, sub {
    my ($class, $req, $res) = @_;
    $res->content_type('application/xml');
    $res->content(scalar $hatena_hatena_rss_f->slurp);
});

1;
