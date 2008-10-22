#!perl
use strict;
use warnings;
use Test::More 'no_plan';
use Test::Differences;
use Pod::Weaver;
use Software::License::Perl_5;

my $pod = <<'END_DOC';
use strict;
package Test::Example::Pod;

# ABSTRACT: this is just a test

=head1 DESCRIPTION

This is a test.  How many times do I need to tell you that?

=method none

Nope, there are no methods.

=attr also_none

None of these, either.

=method i_lied

Ha!  Gotcha!

=cut

sub i_lied { ... }

1;
END_DOC

my $want = <<'END_DOC';
use strict;
package Test::Example::Pod;

# ABSTRACT: this is just a test


sub i_lied { ... }

1;

__END__
=head1 NAME

Test::Example::Pod - this is just a test

=head1 VERSION

version 1.002

=head1 DESCRIPTION

This is a test.  How many times do I need to tell you that?

=head1 ATTRIBUTES

=head2 also_none

None of these, either.

=head1 METHODS

=head2 none

Nope, there are no methods.

=head2 i_lied

Ha!  Gotcha!

=head1 AUTHOR

  E. Xavier Ample <eduardo@example.name>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008 by E. Xavier Ample.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

END_DOC

my $license = Software::License::Perl_5->new({
  year   => 2008,
  holder => 'E. Xavier Ample',
});

my $logger = do {
  package TL; sub log {}; bless {};
};

my $woven = Pod::Weaver->new({ logger => $logger })->munge_pod_string(
  $pod,
  {
    authors => [ 'E. Xavier Ample <eduardo@example.name>' ],
    version => 1.002,
    license => $license,
  },
);

eq_or_diff($woven, $want, 'we rewrote as expected');
