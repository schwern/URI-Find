#!/usr/bin/perl -w

use strict;
use Test::More;

use URI::Find::TransformRules;
my $CLASS = 'URI::Find::TransformRules';

ok( $CLASS->is_balanced("(foo)", ")")        );
ok( !$CLASS->is_balanced("((foo)", ")")      );
ok( !$CLASS->is_balanced(")foo(", ")")       );
ok( $CLASS->is_balanced("<f<>o>o", ">")      );

done_testing();
