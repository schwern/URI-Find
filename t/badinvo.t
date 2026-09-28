#!/usr/bin/perl
use strict;
use warnings;

use URI::Find::Schemeless;
use URI::Find qw/find_uris/;
use Test::More tests => 45;

sub test_badinvo {
    my $test_cb = shift;
    my $error;
    
    eval { &$test_cb } or do {
        $error = $@;
        $error =~ s/\sat.+$//s
    };

    my $message  = shift;
    my $expected = shift;
    is $error, $expected, $message
}

test_badinvo(
    sub { URI::Find->new() }
    , 'URI::Find::new(1) called with no arguments'
    , 'Bogus invocation of URI::Find::new'
);

test_badinvo(
    sub { URI::Find->new(1..1) }
    , 'URI::Find::new(1) called with one argument'
);

test_badinvo(
    sub { URI::Find->new(1..2) }
    , 'URI::Find::new(1) called with two arguments'
    , 'Bogus invocation of URI::Find::new'
);

test_badinvo(
    sub { URI::Find->new(1..3) }
    , 'URI::Find::new(1) called with three arguments'
    , 'Bogus invocation of URI::Find::new'
);

my $f = URI::Find
    ->new(sub { $_[0] });

test_badinvo(
    sub { $f->badinvo() }
    , 'badinvo(0-2) called with no arguments' 
    , 'Bogus invocation of main::__ANON__'
);

test_badinvo(
    sub { $f->badinvo(1..1) }
    , 'badinvo(0-2) called with one argument' 
    , 'Bogus invocation of (eval)'
);

test_badinvo(
    sub { $f->badinvo(1..2) }
    , 'badinvo(0-2) called with two arguments' 
    , 'Bogus invocation of (eval) (2)'
);

test_badinvo(
    sub { $f->badinvo(1..3) }
    , 'badinvo(0-2) called with three arguments' 
    , 'Bogus invocation of (eval) (2)'
);

my $uri = "https://perl.org";

test_badinvo(
    sub { $f->find() }
    , 'find(1-2) called with no arguments' 
    , 'Bogus invocation of URI::Find::find'
);

test_badinvo(
    sub { $f->find(\$uri) }
    , 'find(1-2) called with one argument'
);

test_badinvo(
    sub { $f->find(\$uri, sub { $_[0] }) }
    , 'find(1-2) called with two arguments'
);

test_badinvo(
    sub { $f->find(\$uri, sub { $_[0] }, 3) }
    , 'find(1-2) called with three arguments'
    , 'Bogus invocation of URI::Find::find'
);

test_badinvo(
    sub { $f->uri_re() }
    , 'uri_re(0) called with no arguments'
);

test_badinvo(
    sub { $f->uri_re(1..1) }
    , 'uri_re(0) called with one argument'
    , 'Bogus invocation of URI::Find::uri_re'
);

test_badinvo(
    sub { $f->schemeless_uri_re() }
    , 'schemeless_uri_re(0) called with no arguments'
);

test_badinvo(
    sub { $f->schemeless_uri_re(1..1) }
    , 'schemeless_uri_re(0) called with one argument'
    , 'Bogus invocation of URI::Find::schemeless_uri_re'
);

test_badinvo(
    sub { $f->uric_set() }
    , 'uric_set(0) called with no arguments'
);

test_badinvo(
    sub { $f->uric_set(1..1) }
    , 'uric_set(0) called with one argument'
    , 'Bogus invocation of URI::Find::uric_set'
);

test_badinvo(
    sub { $f->cruft_set() }
    , 'cruft_set(0) called with no arguments'
);

test_badinvo(
    sub { $f->cruft_set(1..1) }
    , 'cruft_set(0) called with one argument'
    , 'Bogus invocation of URI::Find::cruft_set'
);

test_badinvo(
    sub { $f->decruft() }
    , 'decruft(1) called with no arguments'
    , 'Bogus invocation of URI::Find::decruft'
);

test_badinvo(
    sub { $f->decruft(1..1) }
    , 'decruft(1) called with one argument'
);

test_badinvo(
    sub { $f->decruft(1..2) }
    , 'decruft(1) called with two arguments'
    , 'Bogus invocation of URI::Find::decruft'
);

test_badinvo(
    sub { $f->recruft() }
    , 'recruft(1) called with no arguments'
    , 'Bogus invocation of URI::Find::recruft'
);

test_badinvo(
    sub { $f->recruft(1..1) }
    , 'recruft(1) called with one argument'
);

test_badinvo(
    sub { $f->recruft(1..2) }
    , 'recruft(1) called with two arguments'
    , 'Bogus invocation of URI::Find::recruft'
);

test_badinvo(
    sub { $f->schemeless_to_schemed() }
    , 'schemeless_to_schemed(1) called with no arguments'
    , 'Bogus invocation of URI::Find::schemeless_to_schemed'
);

test_badinvo(
    sub { $f->schemeless_to_schemed(1..1) }
    , 'schemeless_to_schemed(1) called with one argument'
);

test_badinvo(
    sub { $f->schemeless_to_schemed(1..2) }
    , 'schemeless_to_schemed(1) called with two arguments'
    , 'Bogus invocation of URI::Find::schemeless_to_schemed'
);

test_badinvo(
    sub { $f->is_schemed() }
    , 'is_schemed(1) called with no arguments'
    , 'Bogus invocation of URI::Find::is_schemed'
);

test_badinvo(
    sub { $f->is_schemed(1..1) }
    , 'is_schemed(1) called with one argument'
    , ''
);

test_badinvo(
    sub { $f->is_schemed(1..2) }
    , 'is_schemed(1) called with two arguments'
    , 'Bogus invocation of URI::Find::is_schemed'
);

test_badinvo(
    sub { eval 'find_uris($uri)' }
    , 'find_uris(2) called with one argument'
    , ''
);

test_badinvo(
    sub { find_uris($uri, sub { $_[0] }) }
    , 'find_uris(2) called with two arguments'
);

test_badinvo(
    sub { eval 'find_uris($uri, sub { $_[0] }, 3)' }
    , 'find_uris(2) called with three arguments'
    , ''
);

test_badinvo(
    sub { $f->_is_uri() }
    , '_is_uri(1) called with no arguments'
    , 'Bogus invocation of URI::Find::_is_uri'
);

test_badinvo(
    sub { $f->_is_uri(\$uri) }
    , '_is_uri(1) called with one argument'
);

test_badinvo(
    sub { $f->_is_uri(1..2) }
    , '_is_uri(1) called with two arguments'
    , 'Bogus invocation of URI::Find::_is_uri'
);

test_badinvo(
    sub { URI::Find::Schemeless->new() }
    , 'URI::Find::Schemeless::new(1) called with no arguments'
    , 'Bogus invocation of URI::Find::new'
);

test_badinvo(
    sub { URI::Find::Schemeless->new(1..1) }
    , 'URI::Find::Schemeless::new(1) called with one argument'
);

test_badinvo(
    sub { URI::Find::Schemeless->new(1..2) }
    , 'URI::Find::Schemeless::new(1) called with two arguments'
    , 'Bogus invocation of URI::Find::new'
);

$f = URI::Find::Schemeless
    ->new(sub { $_[0] });

test_badinvo(
    sub { $f->schemeless_uri_re() }
    , 'URI::Find::Schemeless::schemeless_uri_re(0)'
    . ' called with no arguments'
);

test_badinvo(
    sub { $f->schemeless_uri_re(1..1) }
    , 'URI::Find::Schemeless::schemeless_uri_re(0)'
    . ' called with one argument'
        
    , 'Bogus invocation of'
    . ' URI::Find::Schemeless::schemeless_uri_re'
);

test_badinvo(
    sub { $f->top_level_domain_re() }
    , 'URI::Find::Schemeless::top_level_domain_re(0)'
    . ' called with no arguments'
);

test_badinvo(
    sub { $f->top_level_domain_re(1..1) }
    , 'URI::Find::Schemeless::top_level_domain_re(0)'
    . ' called with one argument'

    , 'Bogus invocation of'
    . ' URI::Find::Schemeless::top_level_domain_re'
);

done_testing();
1
