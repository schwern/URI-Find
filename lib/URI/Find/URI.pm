package URI::Find::URI;

use Mouse;
use URI::Find::Grammar;
use URI::Find::Types;
use URI::Escape;
use URI::Find::TransformRules;

use Readonly;

Readonly my $URI_CLASS => 'URI::Find::IRI';


=head1 NAME

URI::Find::URI - Subclass of URI used by URI::Find to represet found URIs

=head1 SYNOPSIS

  # Works like URI with some new methods
  use URI::Find::URI;

=head1 DESCRIPTION

URI::Find::URI is a subclass of URI.  Its used to represent URIs
found.  It adds a little extra data to the object about the context in
which the URI was found.

=cut

our $Delegate_Class = "URI::Find::IRI";
eval "require $Delegate_Class" or die $@;


sub _delegate {
    my $self = shift;
    return $self->transformed_uri;
}

# At the time of this writing URI objects are scalar refs.
# I can't add anything to it so I have to delegate everything.
our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my($method) = $AUTOLOAD =~ m/([^:]+)$/;

    return $self->transformed_uri->$method(@_);
}


# Complete the illusion that this is a subclass
sub isa {
    my $thing = shift;

    return 1 if $thing->SUPER::isa(@_);

    return 1 if (ref $thing and $thing->_delegate)
                    ? $thing->_delegate->isa(@_) : $Delegate_Class->isa(@_);
    return 0;
}

sub can {
    my $thing = shift;

    return 1 if $thing->SUPER::can(@_);

    # Don't delegate magic methods like DESTROY and BUILD
    return 0 if $_[0] =~ /^[A-Z]+$/;

    return 1 if (ref $thing and $thing->_delegate)
                    ? $thing->_delegate->can(@_) : $Delegate_Class->can(@_);
    return 0;
}


# Replicate URI's overloading as of 1.38.
# Can't copy it because its methods violate encapsulation.
use overload
  '""' => sub { $_[0]->transformed_uri->as_string },
  '==' => sub { _obj_eq(@_)  },
  '!=' => sub { !_obj_eq(@_) },
  fallback => 1
;

# Check if two objects are the same object
sub _obj_eq {
    return overload::StrVal($_[0]) eq overload::StrVal($_[1]);
}


=head1 METHODS

URI::Find::URI acts just like URI with the addition of these methods:

Unless otherwise noted they are all get/set accessors of the form:

  my $value = $uri->method;     # get
  $uri->method($value);         # set

=head3 original_text

The unfiltered text matched.  This is the URI as found in the text
before any trailing artifacts (like probable punctuation) or quoting
has been stripped and any heuristics applied.

This is not a URI object as the contents may not be a URI.

=cut

has original_text => (
    is          => 'rw',
    isa         => 'NotEmptyStr',
);

has original_uri => (
    is          => 'rw',
    isa         => 'URI',
    default     => sub {
        return URI::Find::IRI->new($_[0]->original_text);
    }
);

=head3 decrufted_uri

The original_text with heuristics applied to remove anything which is
probably not part of the URI like trailing puncuation.

=cut

has decrufted_uri => (
    is          => 'rw',
    isa         => 'URI',
    lazy        => 1,
    default     => sub {
        return $_[0]->original_uri if $_[0]->is_quoted;
        return $_[0]->decruft($_[0]->original_uri);
    }
);

=head3 transformed_uri

A version of decrufted_uri which is guaranteed to have a scheme.

=cut

has transformed_uri => (
    is          => 'rw',
    isa         => 'URI',
    lazy        => 1,
    default     => sub {
        return $_[0]->transform($_[0]->decrufted_uri);
    },
);


has is_schemeless => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 0
);


has transform_rules => (
    is          => 'rw',
    isa         => 'URI::Find::TransformRules',
    default     => sub {
        URI::Find::TransformRules->new
    },
);

sub add_scheme {
    my $self = shift;
    my $uri  = shift;

    my $uri_class = ref $uri || $URI_CLASS;
    return $uri if $uri->scheme;

    $self->is_schemeless(1);

    my $host = $uri->opaque;
    return $uri unless $host;

    my($first_part) = $host =~ m{^ ([^\.]+) }x;
    $first_part = '' unless defined $first_part;

    # What scheme should we use?
    my $scheme_map = $self->transform_rules->scheme_map;
    my $scheme = $scheme_map->{$first_part};
    $scheme = $scheme_map->{""} unless defined $scheme;
    return $uri unless defined $scheme;

    # IPv6 addresses go in brackets
    my $copy = $uri;
    $copy =~ s{ ($Grammar{ipv6_address}) }{\[$1\]}x;

    # Add the scheme
    $copy = "$scheme://$copy";
    return $URI_CLASS->new($copy);
}


sub decruft {
    my $self = shift;
    my $uri = shift;
    my $uri_class = ref $uri || $URI_CLASS;

    for my $filter ($self->transform_rules->decruft_filters) {
        $filter->($uri);
    }

    # The filters might cause the URI object to turn back into a string.
    $uri = $uri_class->new($uri) unless ref $uri;
    return $uri;
}


sub transform {
    my $self = shift;
    my $uri  = shift;

    $uri = $self->add_scheme($uri);

    return $uri;
}


=head3 begin_pos

=head3 end_pos

The character position in the original string where the URI starts and
ends.

For example, C<<"Go to www.example.com">> has a C<<begin_pos> of 6 and
an C<<end_pos>> of 15.

=cut

has begin_pos => (
    is          => 'rw',
    isa         => 'PosInt',
    lazy        => 1,
    default     => sub {
        $_[0]->end_pos - length $_[0]->original_text
    }
);

has end_pos => (
    is          => 'rw',
    isa         => 'PosInt',
    lazy        => 1,
    default     => sub {
        $_[0]->begin_pos + length $_[0]->original_text
    }
);

has is_quoted => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 0,
);

sub is_just_scheme {
    my $self = shift;
    return $self->original_text =~ m/^$Grammar{scheme} :$/x;
}


1;
