# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num = 1;
BEGIN { $| = 1; $^W = 1; }
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use URI::Find;
$loaded = 1;
ok(1, 'compile');
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
sub ok {
    my($test, $name) = @_;
    print "not " unless $test;
    print "ok $test_num";
    print " - $name" if defined $name;
    print "\n";
    $test_num++;
}

sub eqarray  {
    my($a1, $a2) = @_;
    return 0 unless @$a1 == @$a2;
    my $ok = 1;
    for (0..$#{$a1}) { 
        unless($a1->[$_] eq $a2->[$_]) {
        $ok = 0;
        last;
        }
    }
    return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 1 }

my %Tests;
BEGIN {
    # ARGH!  URI::URL is inconsistant in how it normalizes URLs!
    # HTTP URLs get a trailing slash, FTP and gopher do not.
    %Tests = (
          '<URL:http://www.perl.com>' => 'http://www.perl.com/', 
          '<ftp://ftp.site.org>'      => 'ftp://ftp.site.org',
          '<ftp.site.org>'            => 'ftp://ftp.site.org',
          'Make sure "http://www.foo.com" is caught' =>
                'http://www.foo.com/',
          'http://www.foo.com'  => 'http://www.foo.com/',
          'www.foo.com'         => 'http://www.foo.com/',
          'ftp.foo.com'         => 'ftp://ftp.foo.com',
          'gopher://moo.foo.com'        => 'gopher://moo.foo.com',
          'I saw this site, http://www.foo.com, and its really neat!'
              => 'http://www.foo.com/',
          'Foo Industries (at http://www.foo.com)'
              => 'http://www.foo.com/',
          'Oh, dear.  Another message from Dejanews.  http://www.deja.com/%5BST_rn=ps%5D/qs.xp?ST=PS&svcclass=dnyr&QRY=lwall&defaultOp=AND&DBS=1&OP=dnquery.xp&LNG=ALL&subjects=&groups=&authors=&fromdate=&todate=&showsort=score&maxhits=25  How fun.'
              => 'http://www.deja.com/%5BST_rn=ps%5D/qs.xp?ST=PS&svcclass=dnyr&QRY=lwall&defaultOp=AND&DBS=1&OP=dnquery.xp&LNG=ALL&subjects=&groups=&authors=&fromdate=&todate=&showsort=score&maxhits=25',
          'Hmmm, Storyserver from news.com.  http://news.cnet.com/news/0-1004-200-1537811.html?tag=st.ne.1002.thed.1004-200-1537811  How nice.'
             => 'http://news.cnet.com/news/0-1004-200-1537811.html?tag=st.ne.1002.thed.1004-200-1537811',
          '$html = get("http://www.perl.com/");' => 'http://www.perl.com/',
          q|my $url = url('http://www.perl.com/cgi-bin/cpan_mod');|
              => 'http://www.perl.com/cgi-bin/cpan_mod'
    );

    $Total_tests += (3 * keys %Tests);
}

while( my($text, $expect) = each %Tests ) {
    my($orig_text) = $text;
    ok( find_uris($text, sub { ok( $_[0] eq $expect );  
                               return $_[1] 
                           } 
                 ) == 1 
      );
    ok( $text eq $orig_text );
}

BEGIN { $Total_tests++ }

# Do all the tests again as one big block of text.
my $mess_text = join "\n", keys %Tests;
ok( find_uris($mess_text, sub { return $_[1] }) == keys %Tests );


# Tests for false positives.
my @FalseTests;
BEGIN {
    @FalseTests = (
                   'HTTP::Request::Common',
                   'comp.infosystems.www.authoring.cgi'
                  );

    $Total_tests += @FalseTests * 2;
}

foreach my $f_text (@FalseTests) {
    my $orig_text = $f_text;
    ok( find_uris($f_text, sub {1}) == 0 );
    ok( $orig_text eq $f_text );
}
