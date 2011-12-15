package HTTest::Mock::Microsoft::Translator;
use strict;
use warnings;
use HTTest::Mock::Server;
use HTTP::Status qw(:constants);

HTTest::Mock::Server->add_handler(qr<\Qhttp://api.microsofttranslator.com/V2/Ajax.svc/Translate\E>, sub {
    my ($server, $req, $res) = @_;
    $res->content_type('application/x-javascript');
    $res->code(HTTP_OK);
    $res->content( '"This is the HTTP responses with Mock. モックからのHTTPレスポンスです."' );
});
