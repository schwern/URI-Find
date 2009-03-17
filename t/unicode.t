#!/usr/bin/perl -w

# What about URLs with Unicode in their path or domain?

use strict;
use Test::More 'no_plan';

use URI::Find;

my %tests = (
    "IDN domains http://➡.ws/䯡 and stuff" => ["http://➡.ws/䯡"],
);

while( my($text, $uris) = each %tests ) {
    my @found;
    my $finder = URI::Find->new(sub { push @found, $_[0]; $_[0] });
    $finder->find(\$text);

    is_deeply \@found, \@$uris, "Original text: $text";
}
    
