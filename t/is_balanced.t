#!/usr/bin/perl -w

use strict;
use Test::More;

use URI::Find;

ok( URI::Find->is_balanced("(foo)", ")")        );
ok( !URI::Find->is_balanced("((foo)", ")")      );
ok( !URI::Find->is_balanced(")foo(", ")")       );
ok( URI::Find->is_balanced("<f<>o>o", ">")      );

done_testing();
