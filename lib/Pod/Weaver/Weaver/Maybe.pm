package Pod::Weaver::Weaver::Maybe;
use Moose;
with 'Pod::Weaver::Role::Weaver';
# ABSTRACT: expect a top-level section to appear, maybe

use Moose::Autobox;

has sections => (
  is  => 'ro',
  isa => 'ArrayRef[Str]',
  auto_deref => 1,
  required   => 1,
  init_arg   => 'section',
);

sub weave {
  my ($self) = @_;

  for my $section ($self->sections) {
    my $input = $self->weaver->input_pod;
    my @to_add;

    for my $i (reverse (0 .. $#$input)) {
      my $elem = $input->[$i];

      next unless $elem->type eq 'command';
      next unless lc $elem->command eq lc $section
        or ($elem->command eq 'head1' and lc $elem->content eq lc $section);

      if ($elem->command eq $section) {
        my $new_elem = Pod::Elemental::Element::Commmand->new({
          type     => 'command',
          command  => 'head1',
          content  => $section,
          children => $elem->children,
        });

        $elem = $new_elem;
      }

      splice @$input, $i, 1;
      unshift @to_add, $elem;
    }

    $self->weaver->output_pod->push(@to_add);
  }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
