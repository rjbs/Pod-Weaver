package Pod::Weaver::Section::Generic;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a generic section, found by lifting sections

use Moose::Autobox;

=head1 OVERVIEW

This section will find and include a located hunk of Pod.  In general, it will
find a C<=head1> command with a content of the plugin's name.

In other words, if your configuration include:

  [Generic]
  header = OVERVIEW

...then this weaver will look for "=head1 OVERVIEW" and include it at the
appropriate location in your output.

Since you'll probably want to use Generic several times, and that will require
giving each use a unique name, you can omit C<header> if you provide a
plugin name, and it will default to the plugin name.  In other words, the
configuration above could be specified just as:

  [Generic / OVERVIEW]

If the C<required> attribute is given, and true, then an exception will be
raised if this section can't be found.

=cut

use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Selectors -all;

=attr required

A boolean value specifying whether this section is required to be present or not. Defaults
to false.

If it's enabled and the section can't be found an exception will be raised.

=cut

has required => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

=attr header

The name of this section. Defaults to the plugin name.

=cut

has header => (
  is   => 'ro',
  isa  => 'Str',
  lazy => 1,
  default => sub { $_[0]->plugin_name },
);

=attr selector

The coderef that implements the search for the specified section. You usually don't need to touch this!

TODO: We need a better way to specify this in the F<weaver.ini> file...

=cut

has selector => (
  is  => 'ro',
  isa => 'CodeRef',
  lazy    => 1,
  default => sub {
    my ($self) = @_;
    return sub {
      return unless s_command(head1 => $_[0]);
      return unless $_[0]->content eq $self->header;
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

  confess "Couldn't find required Generic section for " . $self->header . " in file "
    . $input->{filename} if $self->required and not @found;

  my @to_add;
  for my $i (reverse @found) {
    push @to_add, splice @{ $in_node }, $i, 1;
  }

  $document->children->push(@to_add);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
