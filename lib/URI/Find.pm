package URI::Find;

require 5.005;

use strict;
use base qw(Exporter);
use vars qw($VERSION @EXPORT);
$VERSION = 0.03;
@EXPORT = qw(find_uris);

use constant YES => (1==1);
use constant NO  => !YES;

use URI::URL;

# XXX This is probably more than a little cozy with URI.pm.
require URI;
my($schemeRe) = $URI::scheme_re;
my($uricSet)  = $URI::uric;

# We need to avoid picking up 'HTTP::Request::Common' so we have a
# subset of uric without a colon ("I have no colon and yet I must poop")
my($uricCheat) = $uricSet;
$uricCheat =~ tr/://d;

# Find potential schemeless URIs.  Make sure you don't pick up things
# like 'comp.infosystems.www.cgi'
my($schemelessRe) = qr/(?<!\.)(?:www\.|ftp\.)/;

# Look for schemed URLs or some common schemeless ones.
my($uriRe)    = qr/(?:$schemeRe:[$uricCheat]|$schemelessRe)[$uricSet]*/;


# $urlsmorphed = _morphurls($text, \&callback);
sub find_uris (\$&) {
    my($r_text, $callback) = @_;
    
    my $urlsfound = 0;
    
    # Don't assume http.
    URI::URL::strict(1);
    
    # Yes, evil.  Basically, look for something vaguely resembling a URL,
    # then hand it off to URI::URL for examination.  If it passes, throw
    # it to a callback and put the result in its place.
    local $SIG{__DIE__} = 'DEFAULT';
    my $uri_cand;
    my $uri;
    $$r_text =~ s{(<$uriRe>|$uriRe)}{
        my($orig_match) = $1;
    
        # A heruristic.  Often you'll see things like:
        # "I saw this site, http://www.foo.com, and its really neat!"
        # or "Foo Industries (at http://www.foo.com)"
        # We want to avoid picking up the trailing paren, period or comma.
        # Of course, this might wreck a perfectly valid URI, more often than
        # not it corrects a parse mistake.
        my $end_cruft = '';
        if( $orig_match =~ s|([),.'";]+)$|| ) {
            $end_cruft = $1;
        }

        my $start_cruft = '';

        if( my $uri = _is_uri(\$orig_match) ) { # Its a URI, work with it.
            $urlsfound++;

            # Don't forget to put any cruft we accidentally matched back.
            $start_cruft . $callback->($uri, $orig_match) . $end_cruft;
        }
        else {                        # False alarm.
            # Again, don't forget the cruft.
            $start_cruft . $orig_match . $end_cruft;
        }
    }eg;

    return $urlsfound;
}


sub _is_uri {
    my($r_uri_cand) = @_;
    
    # Another cheat.  Add http:// to schemeless URIs that start with www.
    # and ftp:// to those that start with ftp.
    my $uri = $$r_uri_cand;
    $uri =~ s|^(<?)www\.|$1http://www\.|;
    $uri =~ s|^(<?)ftp\.|$1ftp://ftp\.|;
    
    eval {
        $uri = URI::URL->new($uri);
    };
    
    if($@ || !defined $uri) {	# leave everything untouched, its not a URI.
        return NO;
    }
    else {			# Its a URI.
        return $uri;
    }
}


__END__

=pod

=head1 NAME

  URI::Find - Find URIs in arbitrary text


=head1 SYNOPSIS

  use URI::Find;

  $how_many_found = find_uris($text, \&callback);


=head1 DESCRIPTION

This module does one thing: Finds URIs and URLs in plain text.  It
finds them quickly and it finds them B<all> (or what URI::URL
considers a URI to be.)


=head2 Functions

URI::Find exports one function, find_uris().  It takes two arguments,
the first is a text string to search, the second is a function
reference.  

The function is a callback which is called on each URI found.  It is
passed two arguments, the first is a URI::URL object representing the
URI found.  The second is the original text of the URI found.  The
return value of the callback will replace the original URI in the
text.


=head1 EXAMPLES

Simply print the original URI text found and the normalized
representation.

  find_uris($text, 
            sub {
                my($uri, $orig_uri) = @_;
                print "The text '$orig_uri' represents '$uri'\n";
                return $orig_uri;
            });

Check each URI in document to see if it exists.

  use LWP::Simple;
  find_uris($text,
            sub {
                my($uri, $orig_uri) = @_;
                if( head $uri ) {
                    print "$orig_uri is okay\n";
                }
                else {
                    print "$orig_uri cannot be found\n";
                }
                return $orig_uri;
            });

Wrap each URI found in an HTML anchor.

  find_uris($text,
            sub {
                my($uri, $orig_uri) = @_;
                return qq|<a href="$uri">$orig_uri</a>|;
            });


=head1 SEE ALSO

  L<URI::URL>, L<URI>, RFC 2396

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com> with insight from Uri Gutman, Greg Bacon and Jeff Pinyan.

=cut
