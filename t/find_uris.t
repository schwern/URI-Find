#!/usr/bin/perl
use strict;
use warnings;

use URI::Find qw/find_uris/;
use Test::More 'no_plan';

use lib 't/lib';
use URI::Find::Testing qw/
    get_non_escape_filter_tests
/;

my @tests = get_non_escape_filter_tests();
foreach my $test_data (@tests) {
    my ($msg, $str, $cb, $expected) = @$test_data;

    my $original = $str;
    find_uris($str, sub { $cb->(@_) });
    
    is(
        $str, $expected
        , "$msg (input: '$original')"
    )
}

1
