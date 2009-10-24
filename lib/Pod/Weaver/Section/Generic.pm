package Pod::Weaver::Section::Generic;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a generic section, found by lifting sections

use Moose::Autobox;

=head1 OVERVIEW

This section will find and include a located hunk of Pod.  In general, it will
find a C<=head1> command with a content of the plugin's name.

In other words, if your configuration include:

  [Generic / OVERVIEW]

...then this weaver will look for "=head1 OVERVIEW" and include it at the
appropriate location in your output.

If the C<required> attribute is given, and true, then an exception will be
raised if this section can't be found.

=cut


use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Selectors -all;

has required => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

has selector => (
  is  => 'ro',
  isa => 'CodeRef',
  lazy    => 1,
  default => sub {
    my ($self) = @_;
    return sub {
      return unless s_command(head1 => $_[0]);
      return unless $_[0]->content eq $self->plugin_name;
    };
  },
);

sub weave_section {
  my ($self, $document, $input) = @_;

  my $in_node = $input->{pod_document}->children;
  my @found;
  $in_node->each(sub {
    my ($i, $para) = @_;
    push @found, $i if $self->selector->($para);
  });

  confess "couldn't find requried Generic section for " . $self->plugin_name
    if $self->required and not @found;

  my @to_add;
  for my $i (reverse @found) {
    push @to_add, splice @{ $in_node }, $i, 1;
  }

  $document->children->push(@to_add);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
