package Pod::Weaver;
use Moose;
# ABSTRACT: do horrible things to POD, producing better docs

use List::MoreUtils qw(any);
use Moose::Autobox;
use PPI;
use Pod::Elemental;
use Pod::Elemental::Document;
use Pod::Weaver::Role::Plugin;
use String::Flogger;
use String::RewritePrefix;

=head1 WARNING

This code is really, really sketchy.  It's crude and brutal and will probably
break whatever it is you were trying to do.

Eventually, this code will be really awesome.  I hope.  It will probably
provide an interface to something more cool and sophisticated.  Until then,
don't expect it to do anything but bring sorrow to you and your people.

=head1 DESCRIPTION

Pod::Weaver is a work in progress, which rips apart your kinda-POD and
reconstructs it as boring old real POD.

=cut

{
  package
    Pod::Weaver::_Logger;
  sub log { printf "%s\n", String::Flogger->flog($_[1]) }
  sub new { bless {} => $_[0] }
}

has logger => (
  lazy    => 1,
  default => sub { Pod::Weaver::_Logger->new },
  handles => [ qw(log) ]
);

has input_pod => (
  is   => 'rw',
  isa  => 'Pod::Elemental::Document',
);

has output_pod => (
  is   => 'ro',
  isa  => 'Pod::Elemental::Document',
  lazy => 1,
  required => 1,
  init_arg => undef,
  default  => sub { Pod::Elemental::Document->new },
);

has plugins => (
  is  => 'ro',
  isa => 'ArrayRef[Pod::Weaver::Role::Plugin]',
  required => 1,
  lazy     => 1,
  init_arg => undef,
  default  => sub { [] },
);

sub BUILD {
  my ($self) = @_;

  for my $entry ($self->_config->flatten) {
    my ($plugin_class, $config) = @$entry;
    eval "require $plugin_class; 1" or die;
    $self->plugins->push(
      $plugin_class->new( $config->merge({ weaver  => $self }) )
    );
  }
}

sub plugins_with {
  my ($self, $role) = @_;

  $role =~ s/^-/Pod::Weaver::Role::/;
  my $plugins = $self->plugins->grep(sub { $_->does($role) });

  return $plugins;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
