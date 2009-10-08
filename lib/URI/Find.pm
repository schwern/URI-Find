package URI::Find;

use strict;
use warnings;

use Mouse;
use URI::Find::Types;

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

=cut

has text => (
    is  => 'rw',
    isa => 'StrRef',
    required => 1,
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

=for note
Keep in sync with data below

    irc

Only used of C<<$finder->accept_all_schemes>> is false, which it is by
default.

=for note
Add a simple way to get a more limited list of very common schemes: http, https, ftp...

=cut

has accepted_schemes => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub {
        $_[0]->default_accepted_schemes
    },
);

my @default_accepted_schemes = (
    # The IANA registry of URI schemes
    
    # Permanent URI Schemes
    'aaa', # Diameter Protocol 	[RFC3588]
    'aaas', # Diameter Protocol with Secure Transport 	[RFC3588]
    'acap', # application configuration access protocol 	[RFC2244]
    'cap', # Calendar Access Protocol 	[RFC4324]
    'cid', # content identifier 	[RFC2392]
    'crid', # TV-Anytime Content Reference Identifier 	[RFC4078]
    'data', # data 	[RFC2397]
    'dav', # dav 	[RFC4918]
    'dict', # dictionary service protocol 	[RFC2229]
    'dns', # Domain Name System 	[RFC4501]
    'fax', # fax (historical, see [RFC3966]) 	[RFC2806]
    'file', # Host-specific file names 	[RFC1738]
    'ftp', # File Transfer Protocol 	[RFC1738]
    'go', # go 	[RFC3368]
    'gopher', # The Gopher Protocol 	[RFC4266]
    'h323', # H.323 	[RFC3508]
    'http', # Hypertext Transfer Protocol 	[RFC2616]
    'https', # Hypertext Transfer Protocol Secure 	[RFC2818]
    'iax', # Inter-Asterisk eXchange Version 2 	[RFC-guy-iax-05.txt]
    'icap', # Internet Content Adaptation Protocol 	[RFC3507]
    'im', # Instant Messaging 	[RFC3860]
    'imap', # internet message access protocol 	[RFC5092]
    'info', # Information Assets with Identifiers in Public Namespaces 	[RFC4452]
    'ipp', # Internet Printing Protocol 	[RFC3510]
    'iris', # Internet Registry Information Service 	[RFC3981]
    'iris.beep', # iris.beep 	[RFC3983]
    'iris.xpc', # iris.xpc 	[RFC4992]
    'iris.xpcs', # iris.xpcs 	[RFC4992]
    'iris.lwz', # iris.lwz 	[RFC4993]
    'ldap', # Lightweight Directory Access Protocol 	[RFC4516]
    'mailto', # Electronic mail address 	[RFC2368]
    'mid', # message identifier 	[RFC2392]
    'modem', # modem (historical, see [RFC3966]) 	[RFC2806]
    'msrp', # Message Session Relay Protocol 	[RFC4975]
    'msrps', # Message Session Relay Protocol Secure 	[RFC4975]
    'mtqp', # Message Tracking Query Protocol 	[RFC3887]
    'mupdate', # Mailbox Update (MUPDATE) Protocol 	[RFC3656]
    'news', # USENET news 	[RFC-ellermann-news-nntp-uri-11.txt]
    'nfs', # network file system protocol 	[RFC2224]
    'nntp', # USENET news using NNTP access 	[RFC-ellermann-news-nntp-uri-11.txt]
    'opaquelocktoken', # opaquelocktokent 	[RFC4918]
    'pop', # Post Office Protocol v3 	[RFC2384]
    'pres', # Presence 	[RFC3859]
    'rtsp', # real time streaming protocol 	[RFC2326]
    'service', # service location 	[RFC2609]
    'shttp', # Secure Hypertext Transfer Protocol 	[RFC2660]
    'sieve', # ManageSieve Protocol 	[RFC-ietf-sieve-managesieve-09.txt]
    'sip', # session initiation protocol 	[RFC3261]
    'sips', # secure session initiation protocol 	[RFC3261]
    'snmp', # Simple Network Management Protocol 	[RFC4088]
    'soap.beep', # soap.beep 	[RFC4227]
    'soap.beeps', # soap.beeps 	[RFC4227]
    'tag', # tag 	[RFC4151]
    'tel', # telephone 	[RFC3966]
    'telnet', # Reference to interactive sessions 	[RFC4248]
    'tftp', # Trivial File Transfer Protocol 	[RFC3617]
    'thismessage', # multipart/related relative reference resolution 	[RFC2557]
    'tip', # Transaction Internet Protocol 	[RFC2371]
    'tv', # TV Broadcasts 	[RFC2838]
    'urn', # Uniform Resource Names (click for registry) 	[RFC2141]
    'vemmi', # versatile multimedia interface 	[RFC2122]
    'xmlrpc.beep', # xmlrpc.beep 	[RFC3529]
    'xmlrpc.beeps', # xmlrpc.beeps 	[RFC3529]
    'xmpp', # Extensible Messaging and Presence Protocol 	[RFC5122]
    'z39.50r', # Z39.50 Retrieval 	[RFC2056]
    'z39.50s', # Z39.50 Session 	[RFC2056]
    
    # Provisional URI Schemes
    'afs', # Andrew File System global file names 	[RFC1738]
    'dtn', # DTNRG research and development 	[draft-irtf-dtnrg-arch]
    'mailserver', # Access to data available from mail servers 	[RFC1738]
    'pack', # pack 	[draft-shur-pack-uri-scheme]
    'tn3270', # Interactive 3270 emulation sessions 	[RFC1738]
    
    # Historical URI Schemes
    'prospero', # Prospero Directory Service 	[RFC4157]
    'snews', # NNTP over SSL/TLS 	[RFC-ellermann-news-nntp-uri-11.txt]
    'videotex', # videotex 	[draft-mavrakis-videotex-url-spec]
    'wais', # Wide Area Information Servers 	[RFC4156]

    # Unregistered schemes
    # Keep docs in sync
    'irc',
);

sub default_accepted_schemes {
    return \@default_accepted_schemes;
}


=head3 accept_all_schemes

A boolean indicating whether all schemes should be accepted.

If false C<<accepted_schemes()>> will be used to limit the URIs found.
If true C<<accepted_schemes>> will be ignored.

Defaults to false.

=cut

has accept_all_schemes => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 0,
);

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


=head3 allowed_schemeless_domains



=cut

has allowed_schemeless_domains => (
    is          => 'rw',
    isa         => 'ArrayRef',
    default     => sub {
        $_[0]->default_allowed_schemeless_domains
    }
);

has url_quoting_patterns => (
    is          => 'rw',
    isa         => 'ArrayRef',
    default     => sub {
        $_[0]->default_url_quoting_patterns
    }
);

has ignore_patterns => (
    is          => 'rw',
    isa         => 'ArrayRef',
    default     => sub {
        $_[0]->default_ignore_patterns
    },
);

has uri_filters => (
    is          => 'rw',
    isa         => 'ArrayRef',
    default     => sub {
        $_[0]->default_uri_filters
    },
);

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
