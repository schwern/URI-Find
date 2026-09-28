#!/usr/bin/perl
# https://github.com/schwern/URI-Find/issues/17
# """
# URI first character matching error
#
# The string q{ http:/example.com } should be ignored by
# the find method. Unfortunately line 36 is deleting the
# colon but leaving the backslash that preceeds it.
# Pull request to follow
# """

use strict;
use warnings;

use URI::Find;
use Test::More tests => 2;

my $replacement = 'URI';
my $f = URI::Find->new(sub { $replacement });

my $uri = q{ http:\/\/example.com };
$f->find(\(my $test = $uri));
is(
    $test, $uri
    , 'Should NOT recognize "http:\\/\\/example.com"'
);

$uri = q{ http:\/example.com };
$f->find(\($test = $uri));
is(
    $test, $uri
    , 'Should NOT recognize "http:\\/example.com"'
);

done_testing();
1
