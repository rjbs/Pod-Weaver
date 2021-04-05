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

# BEGIN CODE IMPORTED FROM Dist::Zilla::Role::TextTemplate
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

sub mvp_multivalue_args { return qw(text) }
has text => (
  is      => 'ro',
  lazy    => 1,
  isa     => 'ArrayRef',
  default => sub { [] },
);



has head => (
  is      => 'ro',
  lazy    => 1,
  isa     => 'Int',
  default => 1,
);


has title => (
  is      => 'ro',
  lazy    => 1,
  isa     => 'Str',
  default => sub { $_[0]->plugin_name },
);


has main_module_only => (
  is      => 'ro',
  lazy    => 1,
  isa     => 'Bool',
  default => 0,
);


has is_template => (
  is      => 'ro',
  lazy    => 1,
  isa     => 'Bool',
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

        name        => $input->{distmeta}->{name},
        version     => $input->{distmeta}->{version},
        homepage    => $input->{distmeta}->{resources}->{homepage},
        repository_web   => $input->{distmeta}->{resources}->{repository}->{web},
        repository_url   => $input->{distmeta}->{resources}->{repository}->{url},
        bugtracker_web   => $input->{distmeta}->{resources}->{bugtracker}->{web},
        bugtracker_email => $input->{distmeta}->{resources}->{bugtracker}->{mailto},
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

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Pod::Weaver::Section::GenerateSection - add pod section from an interpolated piece of text

=head1 VERSION

version 1.06

=head1 SYNOPSIS

In your F<weaver.ini>

  [GenerateSection]
  title = HOMEPAGE
  text  = This is the POD for distribution {{$name}}. Check out what we have
  text  = been up to at {{$homepage}}

The title value can be omited if passed as the plugin name:

  [GenerateSection / HOMEPAGE]

=head1 DESCRIPTION

This plugin attempts to be a cross between L<Pod::Weaver::Section::Template> and
L<Dist::Zilla::Plugin::GenerateFile> without the generation of extra files.

The values of text are concatenated and variable names with matching values on
the distribution are interpolated. Specifying the heading level allows one to
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

=head1 ATTRIBUTES

=head2 text

The text to be added to the section. Multiple values are allowed and will be
concatenated. Certain sequences on the text will be replaced (see below).

=head2 head

The heading level of this section. If 0, there will be no heading. Defaults to 1.

=head2 title

The title for this section. It can optionally be omitted and passed as the
plugin name.

=head2 main_module_only

If true, it will add the text only to the main module POD. Defaults to false.

=head2 is_template

If false, it will not attempt to replace the {{}} entries on text. Defaults to
true.

=for Pod::Coverage mvp_multivalue_args

=head1 Text as template

Unless the option C<is_template> is false, the text will be run through
L<Text::Template>.  The variables C<$plugin>, C<$dist>, and C<$distmeta> will be
provided, set to the GenerateSection plugin, C<Dist::Zilla> object, and the
distribution metadata hash respectively. For convenience, the following
variables are also set:

=over

=item $name

=item $version

=item $homepage

=item $repository_web

=item $repository_url

=item $bugtracker_web

=item $bugtracker_email

=back

=for Pod::Coverage weave_section

=head1 AUTHOR

Carnë Draug <cdraug@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013-2017 by Carnë Draug.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
