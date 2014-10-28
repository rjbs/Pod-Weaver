package Pod::Weaver;
# ABSTRACT: weave together a Pod document from an outline

use Moose;
use namespace::autoclean;

=head1 SYNOPSIS

  my $weaver = Pod::Weaver->new_with_default_config;

  my $document = $weaver->weave_document({
    pod_document => $pod_elemental_document,
    ppi_document => $ppi_document,

    license  => $software_license,
    version  => $version_string,
    authors  => \@author_names,
  })

=head1 DESCRIPTION

Pod::Weaver is a system for building Pod documents from templates.  It doesn't
perform simple text substitution, but instead builds a
Pod::Elemental::Document.  Its plugins sketch out a series of sections
that will be produced based on an existing Pod document or other provided
information.

=cut

use File::Spec;
use Log::Dispatchouli 1.100710; # proxy
use Moose::Autobox 0.10;
use Pod::Elemental 0.100220;
use Pod::Elemental::Document;
use Pod::Weaver::Config::Finder;
use Pod::Weaver::Role::Plugin;
use String::Flogger 1;

=attr logger

This attribute stores the logger, which must provide a log method.  The
weaver's log method delegates to the logger's log method.

=cut

has logger => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    Log::Dispatchouli->new({
      ident     => 'Pod::Weaver',
      to_stdout => 1,
      log_pid   => 0,
    });
  },
  handles => [ qw(log log_fatal log_debug) ]
);

=attr plugins

This attribute is an arrayref of objects that can perform the
L<Pod::Weaver::Role::Plugin> role.  In general, its contents are found through
the C<L</plugins_with>> method.

=cut

has plugins => (
  is  => 'ro',
  isa => 'ArrayRef[Pod::Weaver::Role::Plugin]',
  required => 1,
  lazy     => 1,
  init_arg => undef,
  default  => sub { [] },
);

=method plugins_with

  my $plugins_array_ref = $weaver->plugins_with('-Section');

This method will return an arrayref of plugins that perform the given role, in
the order of their registration.  If the role name begins with a hyphen, the
method will prepend C<Pod::Weaver::Role::>.

=cut

sub plugins_with {
  my ($self, $role) = @_;

  $role =~ s/^-/Pod::Weaver::Role::/;
  my $plugins = $self->plugins->grep(sub { $_->does($role) });

  return $plugins;
}

=method weave_document

  my $document = $weaver->weave_document(\%input);

This is the most important method in Pod::Weaver.  Given a set of input
parameters, it will weave a new document.  Different section plugins will
expect different input parameters to be present, but some common ones include:

  pod_document - a Pod::Elemental::Document for the original Pod document
  ppi_document - a PPI document for the source of the module being documented
  license      - a Software::License object for the source module's license
  version      - a version (string) to use in produced documentation

The C<pod_document> should have gone through a L<Pod5
transformer|Pod::Elemental::Transformer::Pod5>, and should probably have had
its C<=head1> elements L<nested|Pod::Elemental::Transformer::Nester>.

The method will return a new Pod::Elemental::Document.  The input documents may
be destructively altered during the weaving process.  If they should be
untouched, pass in copies.

=cut

sub weave_document {
  my ($self, $input) = @_;

  my $document = Pod::Elemental::Document->new;

  $self->plugins_with(-Preparer)->each_value(sub {
    $_->prepare_input($input);
  });

  $self->plugins_with(-Dialect)->each_value(sub {
    $_->translate_dialect($input->{pod_document});
  });

  $self->plugins_with(-Transformer)->each_value(sub {
    $_->transform_document($input->{pod_document});
  });

  $self->plugins_with(-Section)->each_value(sub {
    $_->weave_section($document, $input);
  });

  $self->plugins_with(-Finalizer)->each_value(sub {
    $_->finalize_document($document, $input);
  });

  return $document;
}

=method new_with_default_config

This method returns a new Pod::Weaver with a stock configuration by using only
L<Pod::Weaver::PluginBundle::Default>.

=cut

sub new_with_default_config {
  my ($class, $arg) = @_;

  my $assembler = Pod::Weaver::Config::Assembler->new;

  my $root = $assembler->section_class->new({ name => '_' });
  $assembler->sequence->add_section($root);

  $assembler->change_section('@Default');
  $assembler->end_section;

  return $class->new_from_config_sequence($assembler->sequence, $arg);
}

sub new_from_config {
  my ($class, $arg, $new_arg) = @_;
  
  my $root = $arg->{root} || '.';
  my $name = File::Spec->catfile($root, 'weaver');
  my ($sequence) = Pod::Weaver::Config::Finder->new->read_config($name);

  return $class->new_from_config_sequence($sequence, $new_arg);
}

sub new_from_config_sequence {
  my ($class, $seq, $arg) = @_;
  $arg ||= {};

  my $merge = $arg->{root_config} || {};

  confess("config must be a Config::MVP::Sequence")
    unless $seq and $seq->isa('Config::MVP::Sequence');

  my $core_config = $seq->section_named('_')->payload;

  my $self = $class->new({
    %$merge,
    %$core_config,
  });

  for my $section ($seq->sections) {
    next if $section->name eq '_';

    my ($name, $plugin_class, $arg) = (
      $section->name,
      $section->package,
      $section->payload,
    );

    # $self->log("initializing plugin $name ($plugin_class)");

    confess "arguments attempted to override 'plugin_name'"
      if defined $arg->{plugin_name};

    confess "arguments attempted to override 'weaver'"
      if defined $arg->{weaver};

    $self->plugins->push(
      $plugin_class->new({
        %$arg,
        plugin_name => $name,
        weaver      => $self,
      })
    );
  }

  return $self;
}

__PACKAGE__->meta->make_immutable;
1;
