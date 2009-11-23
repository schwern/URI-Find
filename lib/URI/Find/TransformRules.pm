package URI::Find::TransformRules;

use Mouse;


=head1 NAME

URI::Find::TransformRules - Rules for transforming found text into a URI

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut


=head3 scheme_map

A hash describing how to map schemeless URIs to a scheme.  The key is
compared against the schemeless URI's domain name.

For example, C<<{ www => "http" }>> would make C<<www.example.com>>
into C<<http://www.example.com>>.

An empty key will be used for anything which does not match.  If no
empty is given then the schemeless URI will not be accepted.

The key can take several forms...

    string        Exact match with the first part of the domain
                  "www" matches "www.example.com/foo/bar"

    regex         Match against the entire domain
                  qr{\.org$} matches "www.example.org/wibble"

    code ref      Run against the entire matched string.
                  Returns true on a match, false otherwise.
                  sub { $_[0] =~ /foo/ } matches "example.com/foo"

    empty string  Its value is the default scheme to be used when
                  nothing else matches

Defaults to a reasonable mapping, unknowns are taken as HTTP.

=cut

has scheme_map => (
    is          => 'rw',
    isa         => 'HashRef',
    default     => sub {
        $_[0]->default_scheme_map
    },
);

my %default_scheme_map = (
    www         => 'http',
    ftp         => 'ftp',
    irc         => 'irc',
    news        => 'news',
    ''          => 'http',
);
sub default_scheme_map {
    return \%default_scheme_map;
}


=head3 decruft_filters

Filters to apply to a matched URI to remove syntactically valid
characters which where probably not intended as part of the URI.  For
example, C<<(Look at http://www.example.com)>> would normally match
C<<http://www.example.com)>> but the C<<)>> is not intended as part of
the URI and would be removed.

URIs found use the decrufted version, but the original text is still
available as C<<$uri->original_uri>>.

Defaults to as good a set of heuristics as we can manage.

=cut

has decruft_filters => (
    is          => 'rw',
    isa         => 'ArrayRef[CodeRef]',
    auto_deref  => 1,
    default     => sub {
        $_[0]->default_decruft_filters
    },
);

my %start2end_puncs = (
    "("         => ")",
    "{"         => "}",
    "["         => "]",
    "<"         => ">",
    q[']        => q['],
    q["]        => q["],
);

my %end2start_puncs = %{ _reverse_hash(\%start2end_puncs) };

my $start_puncs = "[". join("", map { "\\$_" } keys %start2end_puncs) . "]";
$start_puncs = qr/$start_puncs/;

my $end_puncs = "[". join("", map { "\\$_" } keys %end2start_puncs) . "]";
$end_puncs = qr/$end_puncs/;

sub _reverse_hash {
    my $hash = shift;

    return +{ map { $hash->{$_} => $_ } keys %$hash };
}


sub default_decruft_filters {
    return [
        # url, => url
        sub { $_[0] =~ s{ [.,!?]$ }{}x },

        # (url => url
        # (url) => url
        sub {
            return unless $_[0] =~ s{ ^ ($start_puncs) }{}x;

            my $end_punc = $start2end_puncs{$1};
            my $qend_punc = quotemeta($end_punc);
            $_[0] =~ s{ $qend_punc $}{}x;
        },

        # url) => url
        # url(foo) => url(foo)
        sub {
            return unless $_[0] =~ m{ ( $end_puncs ) $ }x;
            my $punc = $1;
            my $qpunc = quotemeta($punc);
            $_[0] =~ s/$qpunc $//x unless __PACKAGE__->is_balanced($_[0], $punc);
        }
    ];
}

sub is_balanced {
    my($self, $text, $end) = @_;
    my $start = $end2start_puncs{$end};

    my $balance = 0;
    while($text =~ /( \Q$start\E | \Q$end\E )/xg) {
        $1 eq $start ? $balance++ : $balance--;
        return 0 if $balance < 0;
    }

    return $balance == 0;
}

1;

