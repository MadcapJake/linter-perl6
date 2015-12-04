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
    my $reg = /s/;
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
  sub f($?x) { };
}
