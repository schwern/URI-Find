#!/usr/bin/perl -w

use strict;

use Test::More 'no_plan';

use URI::Find;

my @tests = (
    [undef => 0],
    [0     => 0],
    [1     => 0],
    [-1    => 0],
    [''    => 0],
    [' '   => 0],
    [':'   => 0],
    ['e :' => 0],
    [':e'  => 0],
    ['::'  => 0],
    ['::e' => 0],
    
    ["http://foo.bar"   => 1],
    ["HTTP://foo.bar"   => 1],
    ["Http://foo.bar"   => 1],
    ["HtTp://foo.bar"   => 1],
    ["h ttp://foo.bar"  => 0],
    ["h,ttp://foo.bar"  => 0],
    [" http://foo.bar"  => 0],
    [" HTTP://foo.bar"  => 0],
    [" http://foo.bar " => 0],
    ["Http-://foo.bar"  => 0],
    ["Http ://foo.bar"  => 0],

    ["h:foo.com"        => 1],
    ["h://foo.com"      => 1],
    ["h:/foo.com"       => 1],
    ["h/foo.com"        => 0],
    ["foo.com"          => 0],
    [":foo.com"         => 0],
    ["://foo.com"       => 0],

    ["git+ssh:"         => 1],
    # ["soap.beep:"       => 1], # FAILED
    # ["view-source:"     => 1], # FAILED
    
    ["+foo:"            => 0],
    ["-bar:"            => 0],
    [".baz:"            => 0],

    # https://github.com/schwern/URI-Find/issues/12
    ["e:('')"           => 1],
    ["e:(')"            => 1],
    ["e:"               => 1],
    ["C:"               => 1],
    ["e"                => 0],
);

for my $test (@tests) {
    my($uri, $want) = @$test;
    is !!URI::Find->is_schemed($uri), !!$want, "is_schemed($uri)";
}
