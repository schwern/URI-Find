package URI::Find::Types;

use Mouse::Util::TypeConstraints;

# Some handy types

subtype 'PosInt'
  => as 'Int',
  => where { $_ >= 0 };

# Moose does not consider string overloaded objects as strings.
# So this lets us store stringified URI objects.
subtype 'NotEmptyStr'
  => as 'Defined',
  => where sub {
      require overload;
      return if ref($_) and !overload::Overloaded($_, q[""]);
      return length $_ > 0;
  };

subtype 'StrRef'
  => as 'ScalarRef',
  => where { !ref $$_ };

subtype 'ListHash'
  => as 'HashRef[Bool]';

coerce 'ListHash'
  => from 'ArrayRef'
  => via sub {
      return +{ map { $_ => 1 } @$_ }
  };

1;
