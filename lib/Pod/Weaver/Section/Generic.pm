package Pod::Weaver::Section::Generic;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a generic section, found by lifting sections

use Moose::Autobox;

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

  my $in_node = $input->{document}->children;
  my @found;
  $in_node->each(sub {
    my ($i, $para) = @_;
    push @found, $i if $self->selector->($para);
  });

  my @to_add;
  for my $i (reverse @found) {
    push @to_add, splice @{ $in_node }, $i, 1;
  }

  $document->children->push(@to_add);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
