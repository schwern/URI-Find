#!/usr/bin/perl -w

use strict;


# RFC 3986 Appendix C covers "Delimiting a URI in Context"
# and it has this example...

my $Example = <<"END";
Yes, Jim, I found it under "http://www.w3.org/Addressing/",
but you can probably pick it up from <ftp://foo.example.
com/rfc/>.  Note the warning in <http://www.ics.uci.edu/pub/
ietf/uri/historical.html#WARNING>.
END

# Which should find these URIs
my @Uris = (
      "http://www.w3.org/Addressing/",
      "ftp://foo.example.com/rfc/",
      "http://www.ics.uci.edu/pub/ietf/uri/historical.html#WARNING",
);


use Test::More tests => 1;
use URI::Find;

my @found;
my $finder = URI::Find->new(sub {
    my($uri) = @_;
    push @found, $uri;
});
$finder->find(\$Example);

is_deeply \@found, \@Uris, "RFC 3986 Appendix C example";
