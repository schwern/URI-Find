#!/usr/bin/perl -w

use strict;
use Test::More;

use File::Find;

chdir "lib";
my @files;

find({
    no_chdir    => 1,
    wanted      => sub {
        push @files, $_ if /\.pm$/;
    }
}, ".");

for my $file (@files) {
    my($module) = $file;
    next if $file =~ /#/;  # emacs auto-save

    $module =~ s{^./}{};
    $module =~ s/\.pm$//;
    $module =~ s{/}{::}g;

    require_ok( $module );
}

done_testing();
