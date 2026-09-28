#!/usr/bin/env perl
# https://github.com/schwern/URI-Find/issues/12
# """
# Strings like e:('') get silently modified,
# even without URI matches
# 
# The string e:('') gets modified to e:()'',
# even without a URI match. As far as I can tell, this is
# the simplest string that exhibits this (well, e:(') does
# too), the leading e: is necessary (any character followed
# by a colon), and it only seems to work when there are
# balanced parentheses.
# """

use warnings;
use strict;

use Test::More 'skip_all';
use URI::Find;

my $string = q{e:('')};
my $original = $string; # Copy
my $matches = 0;

URI::Find->new(sub{ $matches++ })->find(\$string);

is($string, $original, 'String unchanged when there are no matches');
is($matches, 0, 'No URIs matched');

done_testing;
