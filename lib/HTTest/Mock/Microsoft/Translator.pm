package HTTest::Mock::Microsoft::Translator;
use strict;
use warnings;
our $VERSION = '1.0';
use HTTest::Mock::Server;

HTTest::Mock::Server->add_handler(qr<\Qhttp://api.microsofttranslator.com/V2/Ajax.svc/Translate\E>, sub {
    my ($server, $req, $res) = @_;
    $res->content_type('application/x-javascript');
    $res->code(200);
    $res->content( '"This is the HTTP responses with Mock. モックからのHTTPレスポンスです."' );
});

1;

=head1 NAME

HTTest::Mock::Microsoft::Translator - Mock for Microsoft Translator API

=head1 SEE ALSO

Microsoft Translator
<http://msdn.microsoft.com/en-us/library/dd576287.aspx>.

Microsoft Translator Developer & Web Master Support
<http://social.msdn.microsoft.com/Forums/en-US/microsofttranslator/threads/>.

=head1 AUTHOR

id:sano, Hatena.

=head1 LICENSE

Copyright 2010 Hatena <http://www.hatena.ne.jp/>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
