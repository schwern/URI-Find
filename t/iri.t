#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;

my $CLASS = 'URI::Find::IRI';
require_ok $CLASS;

my $text = "http://➡.ws/᛽";
my $uri = $CLASS->new($text);
is $uri, $text, "Unicode escaping disabled";


done_testing();
