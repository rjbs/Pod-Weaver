package Pod::Weaver::Section::GenerateSection;
# ABSTRACT: add pod section from an interpolated piece of text

use strict;
use warnings;
use utf8;

use Moose;

with 'Pod::Weaver::Role::Section';

use Pod::Elemental::Element::Nested;
use Pod::Elemental::Element::Pod5::Ordinary;
use Text::Template;

use namespace::autoclean;

=head1 SYNOPSIS

In your F<weaver.ini>

  [GenerateSection]
  title = HOMEPAGE
  text  = This is the POD for distribution {{$name}}. Check out what we have
  text  = been up to at {{$homepage}}

The title value can be omited if passed as the plugin name:

  [GenerateSection / HOMEPAGE]

=head1 DESCRIPTION

This plugin allows the creation of simple text sections, with or without the
use of Text::Template for templated text.

The C<text> parameters become the lines of the template.

The values of text are concatenated and variable names with matching values on
the distribution are interpolated.  Specifying the heading level allows one to
write down a rather long section of POD text without need for extra files. For
example:

  [GenerateSection / FEEDBACK]
  head = 1
  [GenerateSection / Reporting bugs]
  head = 2
  text = Please report bugs when you find them. While we do have a mailing
  text = list, please use the bug tracker at {{$bugtracker_web}}
  text = to report bugs
  [GenerateSection / Homegape]
  head = 2
  text = Also, come check out our other projects at
  text = {{$homepage}}

=head1 TEMPLATE RENDERING

When rendering as a template, the variables C<$plugin>, C<$dist>, and
C<$distmeta> will be provided, set to the GenerateSection plugin,
C<Dist::Zilla> object, and the distribution metadata hash respectively. For
convenience, the following variables are also set:

=for :list
* C<< $name >>
* C<< $version >>
* C<< $homepage >>
* C<< $repository_web >>
* C<< $repository_url >>
* C<< $bugtracker_web >>
* C<< $bugtracker_email >>

=attr text

The text to be added to the section. Multiple values are allowed and will be
concatenated. Certain sequences on the text will be replaced (see below).

=cut

sub mvp_multivalue_args { return qw(text) }
has text => (
  is      => 'ro',
  isa     => 'ArrayRef',
  lazy    => 1,
  default => sub { [] },
);

=attr head

This is the I<X> to use in the C<=headX> that's created.  If it's C<0> then no
heading is added.  It defaults to C<1>.

=cut

has head => (
  is      => 'ro',
  isa     => 'Int',
  lazy    => 1,
  default => 1,
);

=attr title

The title for this section.  If none is given, the plugin's name is used.

=cut

has title => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub { $_[0]->plugin_name },
);

=attr main_module_only

If true, this attribute indicates that only the main module's Pod should be
altered.  By default, it is false.

=cut

has main_module_only => (
  is      => 'ro',
  isa     => 'Bool',
  lazy    => 1,
  default => 0,
);

=attr

If true, the text is treated as a L<Text::Template> template and rendered.
This attribute B<is true by default>.

=cut

has is_template => (
  is      => 'ro',
  isa     => 'Bool',
  lazy    => 1,
  default => 1,
);

sub weave_section {
  my ($self, $document, $input) = @_;

  if ($self->main_module_only) {
    return if $input->{zilla}->main_module->name ne $input->{filename};
  }

  my $text = join ("\n", @{ $self->text });

  if ($self->is_template) {
    my %stash;

    if ($input->{zilla}) {
      %stash = (
        dist      => \($input->{zilla}),
        distmeta  => \($input->{distmeta}),
        plugin    => \($self),

        name        => $input->{distmeta}{name},
        version     => $input->{distmeta}{version},
        homepage    => $input->{distmeta}{resources}{homepage},
        repository_web   => $input->{distmeta}{resources}{repository}{web},
        repository_url   => $input->{distmeta}{resources}{repository}{url},
        bugtracker_web   => $input->{distmeta}{resources}{bugtracker}{web},
        bugtracker_email => $input->{distmeta}{resources}{bugtracker}{mailto},
      );
    }

    $text = $self->fill_in_string($text, \%stash);
  }

  my $element = Pod::Elemental::Element::Pod5::Ordinary->new({ content => $text });

  if ($self->head) {
    $element = Pod::Elemental::Element::Nested->new({
      command  => "head" . $self->head,
      content  => $self->title,
      children => [ $element ],
    });
  }

  push @{ $document->children }, $element;
}

# BEGIN CODE IMPORTED FROM Dist::Zilla::Role::TextTemplate
=attr delim

If given, this must be an arrayref with two elements.  These will be the
opening and closing delimiters of template variable sections.  By default they
are C<{{> and C<}}>.

=cut

has delim => (
  is   => 'ro',
  isa  => 'ArrayRef',
  lazy => 1,
  init_arg => undef,
  default  => sub { [ qw(  {{  }}  ) ] },
);

sub fill_in_string {
  my ($self, $string, $stash, $arg) = @_;

  $self->log_fatal("Cannot use undef as a template string")
    unless defined $string;

  my $tmpl = Text::Template->new(
    TYPE       => 'STRING',
    SOURCE     => $string,
    DELIMITERS => $self->delim,
    BROKEN     => sub { my %hash = @_; die $hash{error}; },
    %$arg,
  );

  $self->log_fatal("Could not create a Text::Template object from:\n$string")
    unless $tmpl;

  my $content = $tmpl->fill_in(%$arg, HASH => $stash);

  $self->log_fatal("Filling in the template returned undef for:\n$string")
    unless defined $content;

  return $content;
}
# END CODE IMPORTED FROM Dist::Zilla::Role::TextTemplate

__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHOR

Carnë Draug <cdraug@cpan.org>
