#!perl
use strict;
use warnings;
use Test::More 'no_plan';
use Test::Differences;
use Pod::Weaver;

my $pod = <<'END_DOC';
use strict;
package Test::Example::Pod;
# ABSTRACT: this is just a test

my $x = <<'END_INNER';
Foo!  Bar!
END_INNER

1;

END_DOC

my $want = <<'END_DOC';
use strict;
package Test::Example::Pod;
# ABSTRACT: this is just a test

my $x = <<'END_INNER';
Foo!  Bar!
END_INNER

1;


__END__
=head1 NAME

Test::Example::Pod - this is just a test

END_DOC

my $logger = do {
  package TL; sub log {}; bless {};
};

my $woven = Pod::Weaver->new({ logger => $logger })->munge_pod_string($pod);

eq_or_diff($woven, $want, 'we rewrote as expected');

