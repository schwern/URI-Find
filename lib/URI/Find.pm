package URI::Find;

use strict;
use warnings;

use Mouse;
use URI::Find::Types;
use URI::Find::URI;

our $VERSION = 20091006;


=head1 NAME

URI::Find - Find URIs in plain text

=head1 SYNOPSIS

  use URI::Find;

  # Simple interface to find all URIs
  my @uris = URI::Find->new->find_all($text);

  # Flexible interface
  my $finder = URI::Find->new;
  my $uris = $finder->from_string_ref(\$text);
  while( my $uri = $uris->next ) {
      print "Found: $uri\n";
  }

=head1 DESCRIPTION

URI::Find is a module to search any text for URIs.  It aims to be
accurate, fast and customizable.

It'll work for URLs since they're a subset of URIs.

=head1 METHODS

=head3 new

=head3 find_all

  my @uris = $finder->find_all($text);

=cut

# Basic characters
my $alpha       = qr{[a-z]}i;
my $hexdigit    = qr{[\da-f]}i;
my $gen_delims  = qr{[:/?#[\]@]};
my $sub_delims  = qr{[!\$&'\(\)*+,;=]};
my $unreserved  = qr{[A-Za-z0-9-._~]};
my $pct_encoded = qr{ % $hexdigit{2} }x;
my $path_char   = qr{$unreserved | $pct_encoded | $sub_delims | [:@] }x;

# Path
my $path        = qr{(?: / | $path_char )+ }x;

# Query
my $query       = $path;

# Fragment
my $fragment    = $path;

# Host
my $ipvfuture   = qr{ v $hexdigit+ \. (?: $unreserved | $sub_delims | : ) }x;
my $ipv6address = qr{(?: $hexdigit | : )+ }x;         # cheating
my $ipv4address = qr{ \d+ \. \d+ \. \d+ \. \d+ }x;               # cheating
my $reg_name    = qr{ (?: $unreserved | $pct_encoded | $sub_delims )+ }x;
my $ip_literal  = qr{\[ (?: $ipv6address | $ipvfuture ) \] }x;
my $host        = qr{$ip_literal | $ipv4address | $reg_name}x;

# Authority
my $port        = qr{ \d+ }x;
my $userinfo    = qr{(?: $unreserved | $pct_encoded | $sub_delims | : )+ }x;
my $authority   = qr{(?:$userinfo \@)? $host (?: : $port)?}x;

# Scheme
my $scheme      = qr{$alpha (?:$alpha |\d | \+ | - | \. )*}x;

# Hier
my $hier_part   = qr{(?://)? $authority? $path?}x;

# URI
my $uri_schemeless = qr{$hier_part (?: \? $query)? (?:\# $fragment)?}x;
my $uri            = qr{ $scheme : $uri_schemeless }x;
my $uri_both       = qr{ (?:$scheme \:)? $uri_schemeless }x;

sub is_just_scheme {
    my $self = shift;
    my $uri = shift;
    return $uri =~ m/^$scheme :$/x;
}


sub find_all {
    my $self = shift;
    my $text = shift;

    my @uris;
    my $uri_regex = $self->accept_schemeless ? $uri_both : $uri;
    SEARCH: while($text =~ /($uri_regex)/g) {
        my $match = $1;

        my $original_uri = URI->new($match);
        my $uri = URI->new($original_uri);

        $self->add_scheme($uri);

        for my $filter ($self->ignore_filters) {
            next SEARCH if $filter->($self, $uri);
        }

        # Ignore URIs which are of an unrecognized scheme
        next SEARCH unless $self->has_accepted_scheme($uri);

        # Decruft the URI
        $uri = URI::Find::URI->new($self->decruft($uri));

        # Store context
        $uri->original_uri($original_uri);
        $uri->end_pos(pos($text));
        $uri->begin_pos(pos($text) - length $1);

        push @uris, $uri;
    }

    return @uris;
}

has text => (
    is  => 'rw',
    isa => 'StrRef',
);


=head2 Configuration

URI::Find strives to DWIM, but you might need to reconfigure it.

The following are methods to configure what URI::Find considers to be
a URI.

Unless otherwise noted they are all accessors which get and set like so:

    # Get
    my $val = $finder->method;

    # Set
    $finder->method($val);

=head3 accepted_schemes

An array ref of schemes to consider as URIs.

What can be a URI is extremely generic.  Without restricting the
possible schemes you'll pick up all sorts of syntactically valid
nonsense.

Defaults to the IANA registered list of schemes, permanent,
provisional and historical plus a few common unregistered schemes:

If empty then all schemes are accepted.

=for note
Keep in sync with data below

    irc

=for note
Add a simple way to get a more limited list of very common schemes: http, https, ftp...

=cut

has accepted_schemes => (
    is          => 'rw',
    isa         => 'ListHash',
    required    => 1,
    coerce      => 1,
    writer      => 'set_accepted_schemes',
    default     => sub {
        $_[0]->default_accepted_schemes;
    },
);

my @default_accepted_schemes = (
    # The IANA registry of URI schemes
    
    # Permanent URI Schemes
    'aaa', # Diameter Protocol  [RFC3588]
    'aaas', # Diameter Protocol with Secure Transport   [RFC3588]
    'acap', # application configuration access protocol         [RFC2244]
    'cap', # Calendar Access Protocol   [RFC4324]
    'cid', # content identifier         [RFC2392]
    'crid', # TV-Anytime Content Reference Identifier   [RFC4078]
    'data', # data      [RFC2397]
    'dav', # dav        [RFC4918]
    'dict', # dictionary service protocol       [RFC2229]
    'dns', # Domain Name System         [RFC4501]
    'fax', # fax (historical, see [RFC3966])    [RFC2806]
    'file', # Host-specific file names  [RFC1738]
    'ftp', # File Transfer Protocol     [RFC1738]
    'go', # go  [RFC3368]
    'gopher', # The Gopher Protocol     [RFC4266]
    'h323', # H.323     [RFC3508]
    'http', # Hypertext Transfer Protocol       [RFC2616]
    'https', # Hypertext Transfer Protocol Secure       [RFC2818]
    'iax', # Inter-Asterisk eXchange Version 2  [RFC-guy-iax-05.txt]
    'icap', # Internet Content Adaptation Protocol      [RFC3507]
    'im', # Instant Messaging   [RFC3860]
    'imap', # internet message access protocol  [RFC5092]
    'info', # Information Assets with Identifiers in Public Namespaces  [RFC4452]
    'ipp', # Internet Printing Protocol         [RFC3510]
    'iris', # Internet Registry Information Service     [RFC3981]
    'iris.beep', # iris.beep    [RFC3983]
    'iris.xpc', # iris.xpc      [RFC4992]
    'iris.xpcs', # iris.xpcs    [RFC4992]
    'iris.lwz', # iris.lwz      [RFC4993]
    'ldap', # Lightweight Directory Access Protocol     [RFC4516]
    'mailto', # Electronic mail address         [RFC2368]
    'mid', # message identifier         [RFC2392]
    'modem', # modem (historical, see [RFC3966])        [RFC2806]
    'msrp', # Message Session Relay Protocol    [RFC4975]
    'msrps', # Message Session Relay Protocol Secure    [RFC4975]
    'mtqp', # Message Tracking Query Protocol   [RFC3887]
    'mupdate', # Mailbox Update (MUPDATE) Protocol      [RFC3656]
    'news', # USENET news       [RFC-ellermann-news-nntp-uri-11.txt]
    'nfs', # network file system protocol       [RFC2224]
    'nntp', # USENET news using NNTP access     [RFC-ellermann-news-nntp-uri-11.txt]
    'opaquelocktoken', # opaquelocktokent       [RFC4918]
    'pop', # Post Office Protocol v3    [RFC2384]
    'pres', # Presence  [RFC3859]
    'rtsp', # real time streaming protocol      [RFC2326]
    'service', # service location       [RFC2609]
    'shttp', # Secure Hypertext Transfer Protocol       [RFC2660]
    'sieve', # ManageSieve Protocol     [RFC-ietf-sieve-managesieve-09.txt]
    'sip', # session initiation protocol        [RFC3261]
    'sips', # secure session initiation protocol        [RFC3261]
    'snmp', # Simple Network Management Protocol        [RFC4088]
    'soap.beep', # soap.beep    [RFC4227]
    'soap.beeps', # soap.beeps  [RFC4227]
    'tag', # tag        [RFC4151]
    'tel', # telephone  [RFC3966]
    'telnet', # Reference to interactive sessions       [RFC4248]
    'tftp', # Trivial File Transfer Protocol    [RFC3617]
    'thismessage', # multipart/related relative reference resolution    [RFC2557]
    'tip', # Transaction Internet Protocol      [RFC2371]
    'tv', # TV Broadcasts       [RFC2838]
    'urn', # Uniform Resource Names (click for registry)        [RFC2141]
    'vemmi', # versatile multimedia interface   [RFC2122]
    'xmlrpc.beep', # xmlrpc.beep        [RFC3529]
    'xmlrpc.beeps', # xmlrpc.beeps      [RFC3529]
    'xmpp', # Extensible Messaging and Presence Protocol        [RFC5122]
    'z39.50r', # Z39.50 Retrieval       [RFC2056]
    'z39.50s', # Z39.50 Session         [RFC2056]
    
    # Provisional URI Schemes
    'afs', # Andrew File System global file names       [RFC1738]
    'dtn', # DTNRG research and development     [draft-irtf-dtnrg-arch]
    'mailserver', # Access to data available from mail servers  [RFC1738]
    'pack', # pack      [draft-shur-pack-uri-scheme]
    'tn3270', # Interactive 3270 emulation sessions     [RFC1738]
    
    # Historical URI Schemes
    'prospero', # Prospero Directory Service    [RFC4157]
    'snews', # NNTP over SSL/TLS        [RFC-ellermann-news-nntp-uri-11.txt]
    'videotex', # videotex      [draft-mavrakis-videotex-url-spec]
    'wais', # Wide Area Information Servers     [RFC4156]

    # Unregistered schemes
    # Keep docs in sync
    'irc',
);

sub default_accepted_schemes {
    return \@default_accepted_schemes;
}

sub has_accepted_scheme {
    my $self = shift;
    my $uri = shift;

    my $scheme = $uri->scheme;
    $scheme = lc $scheme unless $self->case_sensitive_schemes;

    my $schemes = $self->accepted_schemes();

    return 1 unless keys %$schemes;
    return 1 if $schemes->{$scheme};
    return 0;
}


=head3 case_sensitive_schemes

If true C<<accepted_schemes()>> will be considered case sensitive.
"http" will not match "HTTP://foo.com".

Defaults to false.

=cut

has case_sensitive_schemes => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 0,
);

=head3 accept_schemeless

Whether or not to try and find schemeless URIs, for example
C<<www.example.com>>.

Defaults to true.

=cut

has accept_schemeless => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 1,
);

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

Defaults to a reasonable mapping.

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
);
sub default_scheme_map {
    return \%default_scheme_map;
}

sub add_scheme {
    my $self = shift;
    my $uri  = shift;

    return if $uri->scheme;

    my $host = $uri->opaque;
    return unless $host;

    my($first_part) = $host =~ m{^ ([^\.]+) \. }x;
    return unless defined $first_part;

    my $scheme = $self->scheme_map->{$first_part};
    return unless $scheme;

    $uri->opaque("//$uri");
    $uri->scheme($scheme);
    return;
}


=head3 allowed_schemeless_domains

A list of filters of what domain names we'll accept as schemeless
URIs.  This prevents every instance of "foo.bar" from being
interpreted as a schemeless URI.

Defaults to all the IANA accepted TLDs.

If empty all domains are accepted.

=cut

has allowed_schemeless_domains => (
    is          => 'rw',
    isa         => 'ListHash',
    coerce      => 1,
    default     => sub {
        $_[0]->default_allowed_schemeless_domains
    }
);

# Version 2009100600, Last Updated Tue Oct  6 07:07:33 2009 UTC
my @TLDs = qw(
AC
AD
AE
AERO
AF
AG
AI
AL
AM
AN
AO
AQ
AR
ARPA
AS
ASIA
AT
AU
AW
AX
AZ
BA
BB
BD
BE
BF
BG
BH
BI
BIZ
BJ
BM
BN
BO
BR
BS
BT
BV
BW
BY
BZ
CA
CAT
CC
CD
CF
CG
CH
CI
CK
CL
CM
CN
CO
COM
COOP
CR
CU
CV
CX
CY
CZ
DE
DJ
DK
DM
DO
DZ
EC
EDU
EE
EG
ER
ES
ET
EU
FI
FJ
FK
FM
FO
FR
GA
GB
GD
GE
GF
GG
GH
GI
GL
GM
GN
GOV
GP
GQ
GR
GS
GT
GU
GW
GY
HK
HM
HN
HR
HT
HU
ID
IE
IL
IM
IN
INFO
INT
IO
IQ
IR
IS
IT
JE
JM
JO
JOBS
JP
KE
KG
KH
KI
KM
KN
KP
KR
KW
KY
KZ
LA
LB
LC
LI
LK
LR
LS
LT
LU
LV
LY
MA
MC
MD
ME
MG
MH
MIL
MK
ML
MM
MN
MO
MOBI
MP
MQ
MR
MS
MT
MU
MUSEUM
MV
MW
MX
MY
MZ
NA
NAME
NC
NE
NET
NF
NG
NI
NL
NO
NP
NR
NU
NZ
OM
ORG
PA
PE
PF
PG
PH
PK
PL
PM
PN
PR
PRO
PS
PT
PW
PY
QA
RE
RO
RS
RU
RW
SA
SB
SC
SD
SE
SG
SH
SI
SJ
SK
SL
SM
SN
SO
SR
ST
SU
SV
SY
SZ
TC
TD
TEL
TF
TG
TH
TJ
TK
TL
TM
TN
TO
TP
TR
TRAVEL
TT
TV
TW
TZ
UA
UG
UK
US
UY
UZ
VA
VC
VE
VG
VI
VN
VU
WF
WS
XN--0ZWM56D
XN--11B5BS3A9AJ6G
XN--80AKHBYKNJ4F
XN--9T4B11YI5A
XN--DEBA0AD
XN--G6W251D
XN--HGBK6AJ7F53BBA
XN--HLCJ6AYA9ESC7A
XN--JXALPDLP
XN--KGBECHTV
XN--ZCKZAH
YE
YT
YU
ZA
ZM
ZW
);

sub default_allowed_schemeless_domains {
    return \@TLDs;
}


=head3 uri_quoting_patterns

A list of filters of URI quoting styles.  The contents of these are
*always* considered as a URI without regard for how the rest of
URI::Find is configured.  Decrufting filters will be applied.

The filter must return the text to be used as the URI without the
quote.  For example, c<<qr{URL:(\S+)}>>.

XXX Default?

=cut

has url_quoting_patterns => (
    is          => 'rw',
    isa         => 'ArrayRef',
    default     => sub {
        $_[0]->default_url_quoting_patterns
    }
);

sub default_url_quoting_patterns {
    return [];
}

=hea3 ignore_filters

A list of filters to always ignore.

XXX Default?

=cut

has ignore_filters => (
    is          => 'rw',
    isa         => 'ArrayRef[CodeRef]',
    auto_deref  => 1,
    default     => sub {
        $_[0]->default_ignore_filters
    },
);

sub default_ignore_filters {
    return [
        # Just a scheme like "http:" and nothing else
        sub { $_[0]->is_just_scheme($_[1]) },
        
        # Probably a Perl module
        sub { $_[1] =~ qr/^\w+::\w+/ }
    ];
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

my %puncs = (
    ")"         => "(",
    "}"         => "{",
    "]"         => "[",
    ">"         => "<",
);
my $end_puncs = "[". join("", map { "\\$_" } keys %puncs) . "]";
$end_puncs = qr/$end_puncs/;

sub default_decruft_filters {
    return [
        sub { $_[0] =~ s/[.,!?]$// },
        sub {
            return unless $_[0] =~ m{ ( $end_puncs ) $ }x;
            my $punc = $1;
            my $qpunc = quotemeta($punc);
            $_[0] =~ s/$qpunc $//x unless URI::Find->is_balanced($_[0], $punc);
        }
    ];
}

sub is_balanced {
    my($self, $text, $end) = @_;
    my $start = $puncs{$end};

    my $balance = 0;
    while($text =~ /( \Q$start\E | \Q$end\E )/xg) {
        $1 eq $start ? $balance++ : $balance--;
        return 0 if $balance < 0;
    }

    return $balance == 0;
}

sub decruft {
    my $self = shift;
    my $uri = shift;

    for my $filter ($self->decruft_filters) {
        $filter->($uri);
    }

    return $uri;
}


=head1 SEE ALSO

URI::Find uses the following standards and references

* RFC 3986 "Uniform Resource Identifier (URI): Generic Syntax"
  L<http://www.ietf.org/rfc/rfc3986.txt>

* RFC 3490 "Internationalizing Domain Names in Applications (IDNA)"
  L<http://www.rfc-editor.org/rfc/rfc3490.txt>

* IANA list of top-level domains (TLDs)
  L<http://data.iana.org/TLD/tlds-alpha-by-domain.txt>

* IANA URI scheme registry
  L<http://www.iana.org/assignments/uri-schemes.html>

=cut

1;
