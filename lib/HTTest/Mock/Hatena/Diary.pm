package HTTest::Mock::Hatena::Diary;
use strict;
use warnings;
our $VERSION = '1.0';
use HTTest::Mock::Server;
use Path::Class;

my $data_d = file(__FILE__)->dir->subdir('Diary');

# ------ Hatena Keyword ------

HTTest::Mock::Server->add_handler(qr<^\Qhttp://d.hatena.ne.jp/keyword?word=%E6%9D%B1%E4%BA%AC&mode=rss&ie=utf8\E$>, sub {
    my ($class, $req, $res) = @_;

    $res->content_type('application/xml; charset=utf-8');
    $res->content(our $keywordrss ||= $data_d->file('keywordrss')->slurp);
});

HTTest::Mock::Server->add_handler(qr<^http://d.hatena.ne.jp/keywordlog\?klid=1012699$>, sub {
    my ($class, $req, $res) = @_;

    $res->content_type('text/html; charset=euc-jp');
    $res->content(our $keywordlog ||= $data_d->file('keywordlog')->slurp);
});

HTTest::Mock::Server->add_handler(qr<^http://d.hatena.ne.jp/keyword/Emacs\?kid=7383&mode=edit$>, sub {
    my ($class, $req, $res) = @_;

    $res->content_type('text/html; charset=euc-jp');
    $res->content(our $keywordeditemacs ||= $data_d->file('keywordeditemacs')->slurp);
});

1;
