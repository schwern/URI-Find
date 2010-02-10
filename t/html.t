#!/usr/bin/perl -w
use strict;
use warnings;

my $Example = <<"END";

Yes, Jim, I found it under "http://www.w3.org/Addressing/",
but you can probably pick it up from <a href="ftp://foo.example.com/rfc/">the RFC</a>. 
Note the <a class="warning" href="http://www.ics.uci.edu/pub/ietf/uri/historical.html#WARNING" target="_blank">warning</a>.
Also <foo bar>.
END

# Which should find these URIs
my @Uris = (
      "http://www.w3.org/Addressing/",
      "ftp://foo.example.com/rfc/",
      "http://www.ics.uci.edu/pub/ietf/uri/historical.html#WARNING",
);

use Test::More tests => 4;
use URI::Find;

my @found;
my $finder = URI::Find->new(sub {
    my($uri) = @_;
    push @found, $uri;
    return "Link " . scalar @found;
    
});
$finder->find(\$Example);

is_deeply \@found, \@Uris, "found links in HTML";
like($Example, qr/Link 1/, 'link 1 replaced');
like($Example, qr/Link 2/, 'link 2 replaced');
like($Example, qr/Link 3/, 'link 3 replaced');
