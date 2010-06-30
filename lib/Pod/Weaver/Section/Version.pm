package Pod::Weaver::Section::Version;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: add a VERSION pod section

use namespace::autoclean;

=head1 OVERVIEW

This section plugin will produce a hunk of Pod meant to indicate the version of
the document being viewed, like this:

  =head1 VERSION

  version 1.234

It will do nothing if there is no C<version> entry in the input.

=cut

use Moose::Autobox;

use String::Formatter 0.100680 stringf => {
  -as => '_format_version',

  input_processor => 'require_single_input',
  string_replacer => 'method_replace',
  codes => {
    v => sub { $_[0]->{version} },
    d => sub {
      Class::MOP::load_class( 'DateTime', { -version => '0.44' } ); # CLDR fixes
      DateTime->from_epoch(epoch => $^T, time_zone => $_[0]->{self}->time_zone)
              ->format_cldr($_[1]),
    },
    r => sub { $_[0]->{zilla}->name },
    m => sub { $_[0]->{module} },
    t => sub { "\t" },
    n => sub { "\n" },
  },
};

=attr format

The string to use when generating the version string.

Default: version %v

The following variables are available:

=over 4

=item * v - the version

=item * d - the CLDR format for L<DateTime>

=item * n - a newline

=item * t - a tab

=item * r - the name of the dist, present only if you use L<Dist::Zilla> to generate the POD!

=item * m - the name of the module, present only if L<PPI> parsed the document and it contained a package declaration!

=back

=cut

has format => (
  is  => 'ro',
  isa => 'Str',
  default => 'version %v',
);

=attr is_verbatim

A boolean value specifying whether the version paragraph should be verbatim or not.

Default: false

=cut

has is_verbatim => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

=attr time_zone

The timezone to use when using L<DateTime> for the format.

Default: local

=cut

has time_zone => (
  is  => 'ro',
  isa => 'Str', # should be more validated later -- apocal
  default => 'local',
);

sub weave_section {
  my ($self, $document, $input) = @_;
  return unless $input->{version};

  my %args = (
    self => $self,
    version => $input->{version},
  );
  $args{zilla} = $input->{zilla} if exists $input->{zilla};

  if ( exists $input->{ppi_document} ) {
    my $pkg_node = $input->{ppi_document}->find_first('PPI::Statement::Package');
    $args{module} = $pkg_node->namespace if defined $pkg_node;
  }

  my $content = _format_version($self->format, \%args);
  if ( $self->is_verbatim ) {
    $content = Pod::Elemental::Element::Pod5::Verbatim->new({
      content => "  $content",
    });
  } else {
    $content = Pod::Elemental::Element::Pod5::Ordinary->new({
      content => $content,
    });
  }

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => 'VERSION',
      children => [ $content ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
