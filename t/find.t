#!/usr/bin/perl -w

use strict;
use Test::More skip_all => "URI::Find doesn't work";

use URI::Find;

my @Tests = ({
    have    => "http://foo.com",
    want    => [{
        original    => "http://foo.com",
    }],

    have    => "Welcome to HTTP://foo.com, Fool!",
    want    => [{
        original        => "HTTP://foo.com,",
        filtered        => "HTTP://foo.com",
        canonical       => "http://foo.com",
        begin           => 11,
        end             => 26,
    }],
});

my $find = URI::Find->new;
for my $test (@Tests) {
    my @uris = $find->find_all($test->{have});
    uris_ok(\@uris, $test->{want});
}

done_testing();


sub uris_ok {
    my($uris, $wants) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $haves = uris2haves($uris);
    $wants = fill_in_wants($wants);
    return is_deeply($haves, $wants) || diag explain({
        have => $haves,
        want => $wants,
    });
}


my @want_keys = qw(
    original
    filtered
    canonical
    begin
    end
);

my %want_defaults = (
    original    => sub { die "want must have an original" },
    filtered    => sub { $_[0]->{original} },
    canonical   => sub { $_[0]->{filtered} },
    begin       => sub { return 0 },
    end         => sub { $_[0]->{begin} + length $_[0]->{original} },
);

sub fill_in_want_defaults {
    my($want) = shift;
    my %new_want;

    for my $key (@want_keys) {
        my $val = $want_defaults{$key};
        $new_want{$key} =
          defined $want->{$key} ? $want->{$key}
                                : $val->($want);
    }

    return \%new_want;
}

sub uris2haves {
    my($uris) = shift;
    my @haves;

    for my $uri (@$uris) {
        my %have;

        for my $key (@want_keys) {
            $have{$key} = $uri->$key();
        }

        push @haves, \%have;
    }

    return \@haves;
}
