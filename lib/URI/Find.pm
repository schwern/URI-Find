package URI::Find;

use Mouse;
use URI::Find::Grammar;
use URI::Find::Types;
use URI::Find::URI;
use URI::Find::TransformRules;
use URI::Find::SelectionRules;

our $VERSION = 20091006;


=head1 NAME

URI::Find - Find URIs in plain text

=head1 SYNOPSIS

  use URI::Find;

  # Simple interface to find all URIs
  my @uris = URI::Find->new->find_all($text);

  # Flexible interface
  my $finder = URI::Find->new;
  my $uris = $finder->from_string_ref(\$text);
  while( my $uri = $uris->next ) {
      print "Found: $uri\n";
  }

=head1 DESCRIPTION

URI::Find is a module to search any text for URIs.  It aims to be
accurate, fast and customizable.

It'll work for URLs since they're a subset of URIs.

=head1 METHODS

=head3 new

=head3 find_all

  my @uris = $finder->find_all($text);

=cut

has selection_rules => (
    is          => 'rw',
    isa         => 'URI::Find::SelectionRules',
    default     => sub {
        URI::Find::SelectionRules->new
    },
);

has transform_rules => (
    is          => 'rw',
    isa         => 'URI::Find::TransformRules',
    default     => sub {
        URI::Find::TransformRules->new
    },
);

sub find_all {
    my $self = shift;
    my $text = shift;

    my $selection_rules = $self->selection_rules;
    my $transform_rules = $self->transform_rules;

    my @uris;
    my $uri_regex = $selection_rules->accept_schemeless ? $Grammar{uri_both} : $Grammar{uri};
    while($text =~ m{($uri_regex)}gx)
    {
        my $original = $1;
        next unless $original =~ /\S/;

        my $uri = URI::Find::URI->new(
            original_text       => $original,
            transform_rules     => $transform_rules,
            end_pos             => pos($text)
        );
        $uri->is_quoted( $self->uri_is_quoted($uri, \$text) );

        next unless $selection_rules->uri_match($uri);

        push @uris, $uri;
    }

    return @uris;
}

has text => (
    is  => 'rw',
    isa => 'StrRef',
);


sub uri_is_quoted {
    my($self, $uri, $text) = @_;

    my $before = substr($$text, $uri->begin_pos-1, 1)   || "";
    my $after  = substr($$text, $uri->end_pos, 1)       || "";

    if( $before eq '"' and $after eq '"'          or
        $before eq '<' and $after eq '>' )
    {
        return 1;
    }
    else {
        return 0;
    }
}


=head2 Configuration

URI::Find strives to DWIM, but you might need to reconfigure it.

The following are methods to configure what URI::Find considers to be
a URI.

Unless otherwise noted they are all accessors which get and set like so:

    # Get
    my $val = $finder->method;

    # Set
    $finder->method($val);

=cut


=head3 uri_quoting_patterns

A list of filters of URI quoting styles.  The contents of these are
searched more aggressively for URIs, usually just by ignoring
whitespace.

The filter must return the text to be used as the URI without the
quote.  For example, c<<qr{URL:(\S+)}>>.

=cut

has uri_quoting_patterns => (
    is          => 'rw',
    isa         => 'ArrayRef[Regexp]',
    auto_deref  => 1,
    default     => sub {
        $_[0]->default_uri_quoting_patterns
    }
);

sub default_uri_quoting_patterns {
    return [
        qr/^< ([^>]+) >$/x,
        qr/^" ([^"]+) "$/x,
    ];
}


=head1 SEE ALSO

URI::Find uses the following standards and references

* RFC 3986 "Uniform Resource Identifier (URI): Generic Syntax"
  L<http://www.ietf.org/rfc/rfc3986.txt>

* RFC 3490 "Internationalizing Domain Names in Applications (IDNA)"
  L<http://www.rfc-editor.org/rfc/rfc3490.txt>

* IANA list of top-level domains (TLDs)
  L<http://data.iana.org/TLD/tlds-alpha-by-domain.txt>

* IANA URI scheme registry
  L<http://www.iana.org/assignments/uri-schemes.html>

=cut

1;
