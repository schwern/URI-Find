#!/usr/bin/perl -w

use ExtUtils::MakeMaker;

require 5.006;

my $mm_version = $ExtUtils::MakeMaker::VERSION;
$mm_version =~ s/_//;  # turn X.Y_Z into X.YZ

my %mm_params = (
    NAME                => 'URI::Find',

    VERSION_FROM        => "lib/URI/Find.pm",
    ABSTRACT_FROM       => "lib/URI/Find.pm",
    AUTHOR              => 'Michael G Schwern <schwern@pobox.com>',

    PREREQ_PM           => {
        URI            => '1.00',
        URI::URL       => '5.00',
    },
);

$mm_params{LICENSE} = 'perl' if $mm_version >= 6.31;

$mm_params{META_MERGE} = {
    resources => {
        license         => 'http://dev.perl.org/licenses/',
        homepage        => 'http://search.cpan.org/dist/URI-Find',
        bugtracker      => 'http://rt.cpan.org/Public/Dist/Display.html?Name=URI-Find',
        repository      => 'http://github.com/schwern/uri-find/tree/master',
    }
}                               if $mm_version >= 6.46;

WriteMakefile(%mm_params);
