package Pod::Weaver::Plugin::H1Nester;
use Moose;
with 'Pod::Weaver::Role::Transformer';
# ABSTRACT: structure the input pod document into head1-grouped sections

use namespace::autoclean;
use Moose::Autobox;

use Pod::Elemental::Selectors -all;
use Pod::Elemental::Transformer::Nester;

=head1 OVERVIEW

This plugin is very, very simple:  it uses the
L<Pod::Elemental::Transformer::Nester> to restructure the document under its
C<=head1> elements.

=cut

sub transform_document {
  my ($self, $document) = @_;

  my $nester = Pod::Elemental::Transformer::Nester->new({
    top_selector => s_command([ qw(head1) ]),
    content_selectors => [
      s_flat,
      s_command( [ qw(head2 head3 head4 over item back) ]),
    ],
  });

  $nester->transform_node($document);

  return;
}

no Moose;
1;
