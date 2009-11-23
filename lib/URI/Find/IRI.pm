package URI::Find::IRI;

use strict;
use warnings;

use base 'URI';

use URI::Escape ();

sub new {
    # I don't want URI to escape anything, but there's no way to turn it off.
    # So blot out URI::Escape::escape_char().
    no warnings 'redefine';
    local *URI::Escape::escape_char = sub { return $_[0] };

    my $class = shift;
    return $class->SUPER::new(@_);
}

1;
