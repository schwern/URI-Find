package URI::Find::URI;

use Mouse;
use URI::Find::Types;


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

our $Delegate_Class = "URI";
eval "require $Delegate_Class" or die $@;

has _delegate => (
    is          => 'rw',
    isa         => $Delegate_Class,
    required    => 1
);

# At the time of this writing URI objects are scalar refs.
# I can't add anything to it so I have to delegate everything.
our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my($method) = $AUTOLOAD =~ m/([^:]+)$/;

    return $self->_delegate->$method(@_);
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
    return 1 if (ref $thing and $thing->_delegate)
                    ? $thing->_delegate->can(@_) : $Delegate_Class->can(@_);
    return 0;
}


# Replicate URI's overloading as of 1.38.
# Can't copy it because its methods violate encapsulation.
use overload
  '""' => sub { $_[0]->_delegate->as_string },
  '==' => sub { _obj_eq(@_)  },
  '!=' => sub { !_obj_eq(@_) },
  fallback => 1
;

# Check if two objects are the same object
sub _obj_eq {
    return overload::StrVal($_[0]) eq overload::StrVal($_[1]);
}


# Change new() to take just the URI
sub BUILDARGS {
    my($class, $uri) = @_;

    return {
        _delegate => $Delegate_Class->new($uri)
    };
}

=head1 METHODS

URI::Find::URI acts just like URI with the addition of these methods:

Unless otherwise noted they are all get/set accessors of the form:

  my $value = $uri->method;     # get
  $uri->method($value);         # set


=head3 original_uri

A URI representing the unfiltered URI object.  This is the URI as
found in the text before any trailing artifacts (like probable
punctuation) have been stripped.

If $original_uri and $uri are the same C<<$uri->original_uri>> may
return itself.

=cut

has original_uri => (
    is          => 'rw',
    isa         => 'URI',
    default     => sub { $_[0] }
);


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
);

has end_pos => (
    is          => 'rw',
    isa         => 'PosInt',
);

1;
