#!/usr/bin/perl -w

use strict;
use Test::More;
use Test::Deep;

use URI::Find;


my @want_keys = qw(
    original
    filtered
    decrufted
);

my %uri2have = (
    original    => sub { $_[0]->original_uri },
    filtered    => sub { $_[0] },
    decrufted   => sub { $_[0]->decrufted_uri },
);

my %want_defaults = (
    original    => sub { die "want must have an original" },
    filtered    => sub { $_[0]->{original} },
    decrufted   => sub { $_[0]->{original} },
);


my @Tests = (
    {
        have    => "http://foo.com",
        want    => [{
            original    => "http://foo.com",
        }],
    },

    {
        have    => "Welcome to HTTP://foo.com, Fool!",
        want    => [{
            original        => "HTTP://foo.com,",
            decrufted       => "HTTP://foo.com",
            filtered        => "HTTP://foo.com",
        }],
    },

    {
        have    => "Hey (the site is at http://example.com) and junk",
        want    => [{
            original        => "http://example.com)",
            decrufted       => "http://example.com",
            filtered        => "http://example.com",
        }],
    },

    {
        have    => "Things and http://example.com/bar(foo)",
        want    => [{
            original        => "http://example.com/bar(foo)",
        }],
    },

    # Test non-recognized schemes are ignored
    {
        have    => "invalidscheme://foo.com",
        want    => [],
    },

    # Test URIs which are just a scheme (ie. "http:") are ignored
    {
        have    => "Something something http: Dark Side",
        want    => [],
    },

    # Ignore Perl modules
    {
        have    => "Get HTTP::Thing from CPAN!",
        want    => [],
    },

    # Simple schemless
    {
        have    => "At www.example.com",
        want    => [{
            original    => "www.example.com",
            filtered    => "http://www.example.com",
        }],
    },

    # FTP schemeless
    {
        have    => "At ftp.example.com and stuff",
        want    => [{
            original    => "ftp.example.com",
            filtered    => "ftp://ftp.example.com",
        }],
    },

    # Ignore unrecognized domain
    {
        have    => "At blah.stuff and stuff",
        want    => [],
    },

    # Ok domain
    {
        have    => "At blah.com and stuff",
        want    => [{
            original    => 'blah.com',
            filtered    => 'http://blah.com',
        }],
    },

    # (uri) => uri
    {
        have    => 'Blah blah (example.com) blah',
        want    => [{
            original    => '(example.com)',
            decrufted   => 'example.com',
            filtered    => 'http://example.com',
        }]
    },

    # (uri => uri
    {
        have    => 'Blah blah (example.com blah) blah',
        want    => [{
            original    => '(example.com',
            decrufted   => 'example.com',
            filtered    => 'http://example.com',
        }]
    },

    # Bug from RFC 3490
    {
        have => <<'HAVE',
   stored in domain names.  For example, an email address local part is
   sometimes stored in a domain label (hostmaster@example.com would be
   represented as hostmaster.example.com in the RDATA field of an SOA
   record).  IDNA does not update the existing email standards, which
HAVE
        want => [
          {
            original => '(hostmaster@example.com',
            decrufted=> 'hostmaster@example.com',
            filtered => 'mailto:hostmaster@example.com',
          },
          {
            original => 'hostmaster.example.com',
            filtered => 'http://hostmaster.example.com',
          }
        ],
        todo => 'foo@bar.com -> mailto:foo@bar.com mapping',
    },

    # Bare IPv4 address
    {
        have => "blah blah 12.23.45.67 and 345.257.11.0 and 1.2.3.258",
        want => [{
            original    => '12.23.45.67',
            filtered    => 'http://12.23.45.67',
        }],
    },

    # Bare IPv6 address
    {
        have => "blah blah ::ffff:192.0.2.128 and 2001:0db8:1234:0000:0000:0000:0000:0000 and ::1",
        want => [
          {
            original    => '::ffff:192.0.2.128',
            filtered    => 'http://[::ffff:192.0.2.128]',
          },
          {
            original    => '2001:0db8:1234:0000:0000:0000:0000:0000',
            filtered    => 'http://[2001:0db8:1234:0000:0000:0000:0000:0000]',
          },
          {
            original    => '::1',
            filtered    => 'http://[::1]',
          }
        ],
    },

    # Ignore the unspecified IPv6 address (see RFC 2373 2.5.2)
    {
        have => "Stuff and :: things",
        want => []
    },

    # IDNA
    {
        have => "At http://➡.ws/᛽ and stuff",
        want => [{
            original => "http://➡.ws/᛽",
        }],
    },

    # URLs in double quotes, like in the RFC
    {
        have => q["g.." = "http://a/b/c/g.."],
        want => [{
            original => "http://a/b/c/g..",
        }],
        todo => "URIs inside double quotes shouldn't be decrufted",
    },

    # Issues with hosts and IP addresses surrounded by quotes.
    {
        todo => "Proper stripping of quoted URIs",
        have => <<'END',
   might lead a human user to assume that the host is 'cnn.example.com',
   whereas it is actually '10.0.0.1'.  Note that a misleading userinfo
END
        want => [
          {
            original => "cnn.example.com",
            filtered => "http://cnn.example.com",
          },
          {
            original => "10.0.0.1",
            filtered => "http://10.0.0.1",
          },
        ],
    },

    # Issues with hosts and IP addresses surrounded by various things
    {
        have => <<'END',
Blah blah (www.example.com) and (1.2.3.4) with 5.4.2.1!
END
        want => [
          {
            original => "(www.example.com)",
            decrufted=> "www.example.com",
            filtered => "http://www.example.com",
          },
          {
            original => "(1.2.3.4)",
            decrufted=> "1.2.3.4",
            filtered => "http://1.2.3.4",
          },
          {
            original => "5.4.2.1!",
            decrufted=> "5.4.2.1",
            filtered => "http://5.4.2.1",
          },
        ],
    }
);

my $find = URI::Find->new;

my @tests = @ARGV ? $Tests[shift()-1] : @Tests;
for my $test (@tests) {
    my @uris = $find->find_all($test->{have});

    local $TODO = $test->{todo};
    uris_ok(\@uris, $test->{want});
}

done_testing();


sub unoverload {
    my $list = shift;

    my @new;
    for my $hash (@$list) {
        my %new;
        for my $key (keys %$hash) {
            $new{$key} = "$hash->{$key}";
        }
        push @new, \%new;
    }

    return \@new;
}

sub fill_in_want_defaults {
    my $wants = shift;

    my @new_wants;
    for my $want (@$wants) {
        push @new_wants, fill_in_want($want);
    }

    return \@new_wants;
}

sub fill_in_want {
    my $want = shift;
    my %new_want;

    for my $key (@want_keys) {
        my $val = $want_defaults{$key};
        $new_want{$key} = defined $want->{$key} ? $want->{$key}
                                                : $val->(\%new_want);
    }

    return \%new_want;
}

sub uris2haves {
    my($uris) = shift;
    my @haves;

    for my $uri (@$uris) {
        my %have;

        for my $key (@want_keys) {
            $have{$key} = $uri2have{$key}->($uri);
        }

        push @haves, \%have;
    }

    return \@haves;
}


sub uris_ok {
    my($uris, $wants) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $haves = uris2haves($uris);
    $wants = fill_in_want_defaults($wants);

    $haves = unoverload($haves);
    $wants = unoverload($wants);

    return cmp_deeply($haves, $wants) || diag explain({
        have => $haves,
        want => $wants,
    });
}
