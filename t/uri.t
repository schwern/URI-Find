#!/usr/bin/perl -w

use strict;
use Test::More;

use URI::Find::URI;
my $CLASS = "URI::Find::URI";

# Test the subclass fiction works for the class
{
    isa_ok $CLASS, "URI";
    can_ok $CLASS, "canonical";
    can_ok $CLASS, "original_uri";
}


{
    my $string = "http://www.foo.com/";
    my $uri = URI::Find::URI->new($string);

    isa_ok $uri, "URI";
    can_ok $uri, "canonical";
    can_ok $uri, "original_uri";

    is $uri, URI->new($string),     "stringification";

    # Object equality
    ok( $uri != URI->new($string) );
    ok( $uri == $uri );

    is $uri->original_uri, $uri;

    $uri->begin_pos(4);
    $uri->end_pos(12);

    is $uri->begin_pos, 4;
    is $uri->end_pos,  12;

    my $orig_uri = URI->new("http://www.foo.com");
    $uri->original_uri($orig_uri);
    is $uri->original_uri, $orig_uri;
}

done_testing;
