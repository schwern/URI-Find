#!/usr/bin/perl -w

# Test the filter function

use strict;

use URI::Find;
use Test::More 'no_plan';

use lib 't/lib';
use URI::Find::Testing qw/
    simple_escape
    get_filter_tests
/;

my @tests = get_filter_tests();
foreach my $test_data (@tests) {
    my ($msg, $str, $cb, $expected) = @$test_data;

    my $original = $str;
    my $f = URI::Find->new($cb);
    $f->find(\$str, \&simple_escape);
    
    is(
        $str, $expected
        , "$msg (input: '$original')"
    )
}

1
