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

sub takes-one-arg($only-arg) {
  unless 1 == 2 {
    say 'hello!';
    say $only-arg;
    my $reg = /asdasd/;
  }
  my $num = 12;
}
takes-one-arg('hello', 'world');
say 'hello!';

=begin pod
wow this is awesome!
=end pod

{
  my $was_after_fail = 0;
  my $was_after_su = 0;
  my $sub = sub { fail 42; $was_after_fail++ };

  use fatal;
  try { $sub(); $was_after_su++ };

  is $was_after_fail, 0, "fail() causes our sub to return (2)";
  is $was_after_su,  0, "fail() causes our try to die";
}
