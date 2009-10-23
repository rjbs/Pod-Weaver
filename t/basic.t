use strict;
use warnings;

use Test::More;

use Pod::Elemental;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Nester;

use Pod::Weaver;

my $string   = do { local $/; <DATA> };
my $document = Pod::Elemental->read_string($string);

Pod::Elemental::Transformer::Pod5->new->transform_node($document);
Pod::Elemental::Transformer::Nester->new({
  top_selector => s_command('head1'),
  content_selectors => [
    s_command([ qw(head2 head3 head4 over item back) ]),
    s_flat,
  ],
})->transform_node($document);

my $woven = Pod::Weaver->new->weave_document({
  document => $document,
});

print $woven->as_debug_string, "\n";

__DATA__
=pod

=head1 DESCRIPTION

This is a simple document meant to be used in testing Pod::Weaver.

It does not do very much.

=head1 BE FOREWARNED

This is not supported:

  much at all

Happy hacking!

=cut
