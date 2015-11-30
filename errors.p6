# sub might_die(Real $x) {
#      die "negative" if $x < 0;
#      $x.sqrt;
#  }
#
#  for 5, 0, -3, 1+2i -> $n {
#      say "The square root of $n is ", might_die($n);
#
#      CATCH
#          # CATCH sets $_ to the error object,
#          # and then checks the various cases:
#          when 'negative' {
#              # note that $n is still in scope,
#              # since the CATCH block is *inside* the
#              # to-be-handled block
#              say "Cannot take square root of $n: negative"
#          }
#          default {
#              say "Other error: $_";
#          }
#      }
#  }

sub routine($arg) {
  unless 1 == 2 {
    say 'hello!';
    say $arg;
    my $reg = /asdasd/;
  }
  my $num = 12;
}
routine('hello');
say 'hello!';

=begin pod
linters are awesome!
=end pod

use Test;

BEGIN {
  throws-like  Buf.new().Str }, X::Buf::AsStr, method => 'Str';;
  throws-like 'pack("B",  1)',       X::Buf::Pack, directive => 'B';
  throws-like 'Buf.new.unpack("B")', X::Buf::Pack, directive => 'B';
  throws-like 'pack "A2", "mÄ"',     X::Buf::Pack::NonASCII, char => 'Ä';
  throws-like 'my class Foo { method a() { $!bar } }', X::Attribute::Undeclared,
              symbol => '$!bar', package-name => 'Foo', package-kind => 'class',
              what => 'attribute';
  throws-like 'sub f() { $^x }', X::Signature::Placeholder,
              line => 1,
              placeholder => '$^x',
}
