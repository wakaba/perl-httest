package HTTest::Mock::Hatena::Nano;
use strict;
use warnings;
use HTTest::Mock;
use JSON::Functions::XS;

my $replies = q{[{"public_reply_entries":[{"star_url":"http://n.hatena.ne.jp/wakabatan/c/wakabatan/245021340196734720","author":{"url_name":"wakabatan","display_name":"わかば"},"data_category":"1","eid":"245021340196734720","body_text":"nemui?","created_on":1295408222,"reply_to_author":{"url_name":"wakabatan","display_name":"わかば"},"reply_to_eid":"245021340187408836"},{"star_url":"http://n.hatena.ne.jp/wakabatan/c/wakabatan/245021340224144904","author":{"url_name":"wakabatan","display_name":"わかば"},"data_category":"1","eid":"245021340224144904","body_text":"nemui?","created_on":1295408329,"reply_to_author":{"url_name":"wakabatan","display_name":"わかば"},"reply_to_eid":"245021340187408836"}],"eid":"343412212233"},{"non_public_reply_entries":[{"star_url":"http://n.hatena.ne.jp/wakabatan/c/wakabatan/24021364061640796","author":{"url_name":"wakabatan","display_name":"わかば"},"data_category":"1","eid":"245021364061640796","body_text":"コメントなどありますか","created_on":1295501444,"reply_to_author":{"url_name":"wakabatan","display_name":"わかば"},"reply_to_eid":"245021340053724283"}],"eid":"245021340053724283","author":{"url_name":"wakabatan","display_name":"わかば"}},{"public_reply_entries":[],"eid":"245021339986067174","author":{"url_name":"wakabatan","display_name":"わかば"}},{"public_reply_entries":[],"eid":"245021339948382438","author":{"url_name":"wakabatan","display_name":"わかば"}}]};

HTTest::Mock::Server->add_handler(qr<^http://n.hatena.com/replies.json>, sub {
    my ($class, $req, $res) = @_;
    $res->content_type('application/json');
    $res->content($replies);
});

1;
