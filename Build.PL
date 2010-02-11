#!/usr/bin/perl -w

use Module::Build 0.30;

require 5.006;

my $build = Module::Build->new(
    module_name         => 'URI::Find',

    configure_requires  => {
        Module::Build   => '0.30'
    },

    build_requires      => {
        Test::More      => '0.82',
        Module::Build   => '0.30',
    },

    requires            => {
        perl            => '5.6.0',
        URI             => '1.00',
        URI::URL        => '5.00',
    },

    license             => 'perl',

    dist_author => 'Michael G Schwern <schwern@pobox.com>',

    meta_merge => {
        resources => {
            homepage        => 'http://search.cpan.org/dist/URI-Find',
            bugtracker      => 'http://rt.cpan.org/Public/Dist/Display.html?Name=URI-Find',
            repository      => 'http://github.com/schwern/uri-find/tree/master',
        }
    },

    recursive_test_files        => 1,
);

$build->create_build_script;
