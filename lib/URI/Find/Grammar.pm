package URI::Find::Grammar;

use strict;
use warnings;

use base qw(Exporter);

our @EXPORT = qw(%Grammar);

# Basic characters
my %g = (
    alpha       => qr{[a-z]}i,
    hexdigit    => qr{[\da-f]}i,
    gen_delims  => qr{[:/?#[\]@]},
    sub_delims  => qr{[!\$&'\(\)*+,;=>]},
    # consider everything above 7-bit ASCII unreserved to allow for Unicode
    unreserved  => qr{[A-Za-z0-9-._~\x{0080}-\x{FFFF}]},
);
our %Grammar;
*Grammar = \%g;

$g{pct_encoded} = qr{ % $g{hexdigit} {2} }x;
$g{path_char}   = qr{
    $g{unreserved}  |
    $g{pct_encoded} |
    $g{sub_delims}  |
    [:@]
}x;

$g{path}     = qr{(?: / | $g{path_char} )+ }x;
$g{query}    = $g{path};
$g{fragment} = $g{path};

# RFC 3490 3.1.1 about dot seperators
$g{idna_sep}    = qr{ [\x{002E}\x{3002}\x{FF0E}\x{FF61}] }x;

# IPvFuture
$g{ipvfuture}   = qr{ v $g{hexdigit}+ \. (?: $g{unreserved} | $g{sub_delims} | : ) }x;

# IPv4
# Must go from longest to shortest else it'll only match 1 in 128.
$g{dec_octet}    = qr{ 25[0-5] | 2[0-4]\d | 1\d\d | [1-9]\d | \d  }x;       # 1 - 255
$g{ipv4_address} = qr{(?: $g{dec_octet} \. ){3} $g{dec_octet} }x;

# IPv6
$g{ipv6_16}     = qr{$g{hexdigit} {1,4}}x;
$g{ipv6_32}     = qr{(?: $g{ipv6_16} : $g{ipv6_16} ) | $g{ipv4_address} }x;
$g{ipv6_address}= qr{
                                                (?: $g{ipv6_16} : ){6} $g{ipv6_32}        |
                                             :: (?: $g{ipv6_16} : ){5} $g{ipv6_32}        |
 (?:                          $g{ipv6_16} )? :: (?: $g{ipv6_16} : ){4} $g{ipv6_32}        |
 (?: (?: $g{ipv6_16} : ){0,1} $g{ipv6_16} )? :: (?: $g{ipv6_16} : ){3} $g{ipv6_32}        |
 (?: (?: $g{ipv6_16} : ){0,2} $g{ipv6_16} )? :: (?: $g{ipv6_16} : ){2} $g{ipv6_32}        |
 (?: (?: $g{ipv6_16} : ){0,3} $g{ipv6_16} )? :: (?: $g{ipv6_16} : ){1} $g{ipv6_32}        |
 (?: (?: $g{ipv6_16} : ){0,4} $g{ipv6_16} )? ::                        $g{ipv6_32}        |
 (?: (?: $g{ipv6_16} : ){0,5} $g{ipv6_16} )? ::                        $g{ipv6_16}        |
 (?: $g{ipv6_16} : ){0,6} $g{ipv6_16}    ::
}x;

# Hostname
$g{reg_name}    = qr{ (?: $g{unreserved} | $g{pct_encoded} | $g{sub_delims} )+ }x;
$g{dotted_domain} = qr{(?: $g{reg_name} $g{idna_sep} ){1,} $g{reg_name} }x;        # foo.bar
$g{ip_literal}  = qr{\[ (?: $g{ipv6_address} | $g{ipvfuture} ) \] }x;
$g{host}        = qr{$g{ip_literal} | $g{ipv4_address} | $g{reg_name}}x;
# A more restricted version for schemeless searches
$g{dotted_host} = qr{$g{ip_literal} | $g{ipv4_address} | $g{dotted_domain}}x;

# Authority
$g{port}        = qr{ \d+ }x;
$g{userinfo}    = qr{(?: $g{unreserved} | $g{pct_encoded} | $g{sub_delims} | : )+ }x;
$g{authority}        = qr{(?:$g{userinfo} \@)? $g{host}        (?: :$g{port})?}x;
$g{dotted_authority} = qr{(?:$g{userinfo} \@)? $g{dotted_host} (?: :$g{port})?}x;

# Scheme
$g{scheme}      = qr{$g{alpha} (?:$g{alpha} |\d | \+ | - | \. )*}x;

# Hier
$g{hier_part}   = qr{(?://)? $g{authority}? $g{path}?}x;

# URI
$g{uri_schemeless} = qr{(?:
    (?: $g{dotted_authority} $g{path}? (?: \? $g{query})? (?:\# $g{fragment})?) |
    $g{ipv6_address}       # otherwise this has to be in brackets
)}x;
$g{uri}            = qr{(?: $g{scheme} : $g{hier_part}
                            (?: \? $g{query})? (?:\# $g{fragment})?
                     )}x;
$g{uri_both}       = qr{(?: $g{uri} | $g{uri_schemeless} )}x;

1;
