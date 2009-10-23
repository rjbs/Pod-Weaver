package Pod::Weaver::Section::Collect;
use Moose;
with 'Pod::Weaver::Role::Section';
with 'Pod::Weaver::Role::Preparer';
# ABSTRACT: a section that gathers up specific commands

use Moose::Autobox;

use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Selectors -all;

has command => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

has new_command => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
  default  => 'head2',
);

has header => (
  is  => 'ro',
  isa => 'Str',
  lazy     => 1,
  required => 1,
  default  => sub { $_[0]->plugin_name },
);

use Pod::Elemental::Transformer::Gatherer;
use Pod::Elemental::Transformer::Nester;

has __used_container => (is => 'rw');

sub prepare_input {
  my ($self, $input) = @_;

  my $document = $input->{document};
  my $selector = s_command($self->command);

  return unless $document->children->grep($selector)->length;

  my $nester = Pod::Elemental::Transformer::Nester->new({
     top_selector      => $selector,
     content_selectors => [
       s_command([ qw(head2 head3 head4 over item back) ]),
       s_flat,
     ],
  });

  my $container = Pod::Elemental::Element::Nested->new({
    command => "head1",
    content => $self->header,
  });

  $self->__used_container($container);

  my $gatherer = Pod::Elemental::Transformer::Gatherer->new({
    gather_selector => $selector,
    container       => $container,
  });

  $nester->transform_node($document);
  $gatherer->transform_node($document);
  $container->children->each_value(sub {
    $_->command( $self->new_command ) if $_->command eq $self->command;
  });
}

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless $self->__used_container;

  my $in_node = $input->{document}->children;
  my @found;
  $in_node->each(sub {
    my ($i, $para) = @_;
    push @found, $i if ($para == $self->__used_container)
                    && $self->__used_container->children->length;
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
