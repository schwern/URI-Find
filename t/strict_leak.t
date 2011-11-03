#!/usr/bin/env perl -w

# Test that URI::URL::strict does not remain on if a callback or filter dies.
# rt.cpan.org 71153

use strict;
use warnings;

use Test::More;

use URI::Find;

note "with a dying callback"; {
    my $text = "Foo http://example.com bar";
    my $finder = URI::Find->new( sub { die; } );

    URI::URL::strict(0);
    ok !URI::URL::strict();
    ok !eval { $finder->find(\$text); 1 };
    ok !URI::URL::strict();    
}


note "with a dying filter"; {
    my $text = "Foo http://example.com bar";
    my $finder = URI::Find->new( sub {} );

    URI::URL::strict(0);
    ok !URI::URL::strict();
    ok !eval { $finder->find(\$text, sub { die; }); 1 };
    ok !URI::URL::strict();    
}


done_testing;
