package URI::Find::Types;

use Mouse::Util::TypeConstraints;

# Some handy types

subtype 'PosInt'
  => as 'Int',
  => where { $_ >= 0 };

subtype 'NotEmptyStr'
  => as 'Str',
  => where { length $_ > 0 };

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
