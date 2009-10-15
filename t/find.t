#!/usr/bin/perl -w

use strict;
use Test::More;
use Test::Deep;

use URI::Find;


my @want_keys = qw(
    original
    filtered
    begin
    end
);

my %uri2have = (
    original    => sub { $_[0]->original_uri },
    filtered    => sub { $_[0] },
    begin       => sub { $_[0]->begin_pos },
    end         => sub { $_[0]->end_pos },
);

my %want_defaults = (
    original    => sub { die "want must have an original" },
    filtered    => sub { $_[0]->{original} },
    begin       => sub { return 0 },
    end         => sub { $_[0]->{begin} + length $_[0]->{original} },
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
            filtered        => "HTTP://foo.com",
            begin           => 11,
            end             => 26,
        }],
    },

    {
        have    => "Hey (the site is at http://example.com) and junk",
        want    => [{
            original        => "http://example.com)",
            filtered        => "http://example.com",
            begin           => 20,
        }],
    },

    {
        have    => "Things and http://example.com/bar(foo)",
        want    => [{
            original        => "http://example.com/bar(foo)",
            begin           => 11,
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
            begin       => 3
        }],
    },

    # FTP schemeless
    {
        have    => "At ftp.example.com and stuff",
        want    => [{
            original    => "ftp.example.com",
            filtered    => "ftp://ftp.example.com",
            begin       => 3
        }],
    },

    # Ignore unrecognized host
    {
        have    => "At blah.stuff and stuff",
        want    => [],
    },
);

my $find = URI::Find->new;
for my $test (@Tests) {
    my @uris = $find->find_all($test->{have});
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