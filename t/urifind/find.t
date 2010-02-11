#!/usr/bin/perl -w
# vim:set ft=perl:

use strict;
use Test::More;
use File::Spec;

plan tests => 13;

ok(my $ifile = File::Spec->catfile(qw(t urifind sciencenews)),
    "Test file found");
my $urifind = File::Spec->catfile(qw(blib script urifind));
my @data = `$^X $urifind $ifile`;

is(scalar @data, 13, "Correct number of elements");
is(scalar(grep /mailto:/ => @data), 4, "Found 4 mailto links");
is(scalar(grep /http:/ => @data), 9, "Found 9 mailto links");

@data = `$^X $urifind $ifile -p`;
my $count = 0;
is(scalar @data, 13, "*Still* correct number of elements");
is(scalar(grep /^$ifile/ => @data), scalar(@data),
    "All elements are prefixed with the path when $urifind invoked with -p");

@data = `$^X $urifind -n $ifile /dev/null`;
is(scalar @data, 13, "*Still* correct number of elements");
is(scalar(grep !/^$ifile/ => @data), scalar(@data),
    "All elements are not prefixed with the path when ($urifind,".
    " '/dev/null') invoked with -n");

@data = `$^X $urifind -S http $ifile`;
is(scalar @data, 9, "Correct number of 'http' elements");

@data = `$^X $urifind -S mailto $ifile`;
is(scalar @data, 4, "Correct number of 'mailto' elements");

@data = `$^X $urifind -S mailto -S http $ifile`;
is(scalar @data, 13, "Correct number of ('http', 'mailto') elements");

@data = `$^X $urifind < $ifile`;
is(scalar @data, 13, "Correct number elements when given data on STDIN");

@data = `$^X $urifind -S http -P \.org $ifile`;
is(scalar @data, 8, "Correct number elements when invoked with -P \.org -S http");
