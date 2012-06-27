package HTTest::Response;
use strict;
use warnings;
our $VERSION = '2.0';
use Encode;

sub new {
    my ($class, @args) = @_;
    if (@args && $args[0] && $args[0] =~ m/^[0-9]{3}$/) {
        # XXX doesn't support specifying headers
        my @names = qw/code message _headers content/;
        @args = map { shift @names => $_ } @args;
    }
    return bless {@args}, $class;
}

sub isa {
    my $class = shift;
    my $class2 = $_[0];
    if ($class2 eq 'HTTP::Response') {
        return 1;
    } else {
        $class->SUPER::isa(@_);
    }
}

sub AUTOLOAD {
    if (our $AUTOLOAD =~ /([^:]+)$/) {
        no strict 'refs';
        my $name = $1;
        *$AUTOLOAD = sub {
            my $self = shift;
            if (@_) {
                $self->{$name} = shift;
            }
            return $self->{$name};
        };
        goto &$AUTOLOAD;
    } else {
        die "AUTOLOAD: no $AUTOLOAD";
    }
}

sub is_info {
    my $self = shift;
    return $self->{is_info} || ($self->{code} =~ /^1..$/);
}

sub is_success {
    my $self = shift;
    return not ($self->is_error or $self->is_redirect or $self->is_info);
}

sub is_redirect {
    my $self = shift;
    return $self->{is_redirect} || ($self->{code} =~ /^3..$/);
}

sub is_error {
    my $self = shift;
    return $self->{is_error} || ($self->{code} !~ /^[1-3]..$/);
}

sub set_json {
    my ($self, $obj) = @_;
    $self->content_type('application/json');
    my $perl2json_bytes_for_record;
    eval {
        require Updu::Util::JSON;
        $perl2json_bytes_for_record = \&Updu::Util::JSON::perl2json_bytes_for_record;
    };
    if ($@) {
        eval {
            require JSON::Functions::XS;
            $perl2json_bytes_for_record = \&JSON::Functions::XS::perl2json_bytes_for_record;
        };
        if ($@) {
            # XXX
        }
    }
    $self->content($perl2json_bytes_for_record->($obj));
}

sub status_line {
    my $self = shift;
    return sprintf '%s %s', $self->code, $self->message;
}

sub content_type {
    my $self = shift;
    if (@_) {
        $self->{header}->{'content-type'} = shift;
    }
    return $self->{header}->{'content-type'};
}

sub header {
    my $self = shift;
    $self->{header} ||= +{};
    if (1 == scalar @_) {
        my $field_name = lc shift;
        $self->{header}->{$field_name};
    } else {
        my %f = @_;
        $self->{header} = {
            %{$self->{header}},
            (map { ((lc $_) => $f{$_}) } keys %f),
        }
    }
}

sub header_as_string {
    my $self = shift;
    return $self->status_line . "\x0D\x0A" . join '', map { $_ . ': ' . $self->{header}->{$_} . "\x0D\x0A" } keys %{$self->{header} or {}};
}

sub server_not_found {
    my $self = shift;
    $self->code(500);
    $self->message(q[Can't connect to requestedhost (Bad hostname 'requestedhost')]);
    $self->content_type('text/plain');
    $self->header('Client-Date: Thu, 17 Jun 2010 05:09:35 GMT');
    $self->header('Client-Warning' => 'Internal response');
    $self->content($self->status_line);
}

# ------ HTTP::Response::Encoding compatible interface ------

sub charset {
    my $self = shift;
    my $ct = $self->header('Content-Type') || '';
    if ($ct =~ /\bcharset=([0-9A-Za-z_-]+)\b/) {
        return $self->{__charset} ||= $1;
    }
    return undef;
}

sub encoder {
    my $self = shift;
    require Encode;
    return $self->{__encoder} ||= Encode::find_encoding($self->charset || return);
}

sub encoding {
    my $self = shift;
    return (($self->encoder || return)->name);
}

sub content_is_xml {
    my $ct = shift->content_type;
    return 1 if $ct eq "text/xml";
    return 1 if $ct eq "application/xml";
    return 1 if $ct =~ /\+xml$/;
    return 0;
}

sub content_is_text {
    my $self = shift;
    return $self->content_type =~ m,^text/,;
}

sub decoded_content {
    my $self = shift;
    if ($self->content_is_xml || $self->content_is_text) {
        my %args = (raise_error => 1, @_);
        my $encoder = $self->encoder or do {
            die "Unknown encoding" if $args{raise_error};
            return undef;
        };
        return $encoder->decode($self->content);
    }
    return $self->content;
}
1;
