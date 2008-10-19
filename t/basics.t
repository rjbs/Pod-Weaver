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

=pod

=head1 NAME

Test::Example::Pod - this is just a test

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

=cut 


END_DOC

my $woven = Pod::Weaver->new->munge_pod_string($pod);

eq_or_diff($woven, $want, 'we rewrote as expected');

