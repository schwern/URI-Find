#!perl -w
use strict;

# $Id: load-schemeless.t,v 1.2 2001/07/27 12:41:54 roderick Exp $

# An error in base.pm in 5.005_03 causes it not to load URI::Find when
# invoked from URI::Find::Schemeless.  Prevent regression.

BEGIN {
    print "1..1\n";
}

print eval { require URI::Find::Schemeless;
		URI::Find::Schemeless->new(sub {}) }
	? "ok 1\n"
	: "not ok 1 ($@)\n";
