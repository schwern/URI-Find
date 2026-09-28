#!/usr/bin/perl
use strict;
use warnings;

use URI::Find;
use Test::More tests => 44;

sub run_tests {
    my $f = shift;

    while (@_) {
        my $t = shift;
        my ($str, $expected) = @$t;

        my $result = $f
            ->schemeless_to_schemed($str);

        is(
            $result, $expected,
            "schemeless_to_schemed '$str'"
        )
    }
}

my $callback = sub { $_[0] };
my $f = URI::Find->new($callback);

my @tests = (
    ['', 'http://'],
    [' ', 'http:// '],
    # [undef, 'http://'], # ERROR
    
    [0, 'http://0'],
    [1, 'http://1'],
    [-1, 'http://-1'],
    [11_111.11, 'http://11111.11'],
    [-11_111.11, 'http://-11111.11'],
    
    [qr{^<perl.com}, 'http://(?-xism:^<perl.com)'],
    [qr{^ftp.myserver.gov}, 'http://(?-xism:^ftp.myserver.gov)'],
    [qr{^<ftp.myserver.gov}, 'http://(?-xism:^<ftp.myserver.gov)'],
    [qr{^<https://perl.com}, 'http://(?-xism:^<https://perl.com)'],

    ['  <', 'http://  <'],
    ['  <<', 'http://  <<'],
    ['  <>', 'http://  <>'],
    ['  ftp.', 'http://  ftp.'],
    ['  ftp..', 'http://  ftp..'],
    ['  duckduckgo.com', 'http://  duckduckgo.com'],
    
    ['^<perl.com', 'http://^<perl.com'],
    ['^ftp.myserver.gov', 'http://^ftp.myserver.gov'],
    ['^<ftp.myserver.gov', 'http://^<ftp.myserver.gov'],
    ['^<https://perl.com', 'http://^<https://perl.com'],
    
    ['<perl.com', '<http://perl.com'],
    ['<http.perl.com>', '<http://http.perl.com>'],
    ['<http.perl.com>', '<http://http.perl.com>'],
    ['ftp.myserver.gov', 'ftp://ftp.myserver.gov'],
    ['<ftp.myserver.gov', '<ftp://ftp.myserver.gov'],
    ['<https://perl.com', '<http://https://perl.com'],
    ['<https://perl.com', '<http://https://perl.com'],
    ['<ftp.myserver.gov>', '<ftp://ftp.myserver.gov>'],
    ['<<ftp.myserver.gov>', '<http://<ftp.myserver.gov>'],
    
    ['myserver.gov', 'http://myserver.gov'],
    ['http.perl.org', 'http://http.perl.org'],
    ['http.perl.org', 'http://http.perl.org'],
    ['ftp://myserver.gov', 'http://ftp://myserver.gov'],
    ['https.facebook.com', 'http://https.facebook.com'],
    ['https://myserver.gov', 'http://https://myserver.gov'],
    ['https://facebook.com', 'http://https://facebook.com'],
    ['ftp://ftp.myserver.gov', 'http://ftp://ftp.myserver.gov'],
    ['ftp://ftp.myserver.gov/', 'http://ftp://ftp.myserver.gov/'],
    ['http://http.myserver.gov', 'http://http://http.myserver.gov'],
    ['ftp://ftp.myserver.gov//', 'http://ftp://ftp.myserver.gov//'],
    ['ftp://ftp.myserver.gov/#', 'http://ftp://ftp.myserver.gov/#'],
    ['ftp://ftp.myserver.gov//?', 'http://ftp://ftp.myserver.gov//?'],
    ['ftp://ftp.myserver.gov/#test', 'http://ftp://ftp.myserver.gov/#test'],
);

run_tests($f, @tests);
done_testing();
1
