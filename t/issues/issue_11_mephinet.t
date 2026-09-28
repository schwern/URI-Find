#! /usr/bin/env perl

# https://github.com/schwern/URI-Find/issues/11
# https://gist.github.com/mephinet/68c6c85aec5655b55342
# """
# When using URI::Find in two-callback-mode, I would expect
# every character of the original string to show up as
# argument in either the URI- or the text-callback.
# 
# However, as the unittest in gist https://[...] shows,
# punctuation immediately following a URI is not reported
# by either of the two callbacks.
# """

use Test::More;
use warnings;
use strict;

use URI::Find;

my $original =<<EOT;
The first sentence ends with a link to http://www.perl.org. The second sentence contains no link.
EOT

my $s1 = $original;    
my $s2 = '';
    
sub cb1 {
    my ($uri, $text) = @_;
    $s2 .= $text;
    return '';
}

sub cb2 {
    my ($text) = @_;
    $s2 .= $text;
    return '';
}

my $finder = URI::Find->new(\&cb1);
$finder->find(\$s1, \&cb2);

is($s2, $original, 'all text moved from $s1 to $s2');
is($s1, '', 'no text is left in $s1');
done_testing;
