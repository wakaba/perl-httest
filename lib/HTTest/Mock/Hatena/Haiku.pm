package HTTest::Mock::Hatena::Haiku;
use strict;
use warnings;
use HTTest::Mock;

our $LastAccess = {};

HTTest::Mock::Server->add_handler(qr<^http://(h(?:1.*)?).hatena.(ne.jp|com)/entry>, sub {
    my ($class, $req, $res) = @_;
    $LastAccess = {subdomain => $1, tld => $2 eq 'com' ? 'com' : 'jp'};
    $LastAccess->{Cookie} = $req->header('Cookie');
    $LastAccess->{params} = {
      %{$class->get_get_params_from_req_as_hash($req)},
      %{$class->get_post_params_from_req_as_hash($req)},
    };
});

1;
