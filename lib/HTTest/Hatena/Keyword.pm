package HTTest::Hatena::Keyword;
use strict;
use warnings;
our $VERSION = '1.0';

our $BodyToKeywords;
our $BodyPatternToKeywords;
{
    use utf8;
    $BodyToKeywords = {
        'Hatena' => ['Hatena'],
        'はてな' => ['はてな'],
        'はてな naoya' => ['はてな', 'naoya'],
        '<p>emacs</p>
<p>vim</p>
' => ['emacs', 'vim'],
        '<p>emacs</p>
<p>vim</p>
<p>秀丸</p>
' => ['emacs', 'vim', '秀丸'],
    };
    $BodyPatternToKeywords = [
        qr!はてな! => ['はてな'],
    ];
}

sub extract {
    my ($class, $body, $args) = @_;
    my $keywords = $BodyToKeywords->{$body} || do {
        my $keywords = [];
        my @pairs = @$BodyPatternToKeywords;
        while (my ($re, $k) = splice @pairs, 0, 2) {
            if ($body =~ $re) {
                $keywords = $k;
                last;
            }
        }
        $keywords;
    };
    return wantarray ? @$keywords : $keywords;
}

1;
