package Pod::Weaver;
use Moose;
# ABSTRACT: do horrible things to Pod, producing better docs

use List::MoreUtils qw(any);
use Moose::Autobox;
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

Pod::Weaver is a work in progress, which rips apart your kinda-Pod and
reconstructs it as boring old real Pod.

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

has plugins => (
  is  => 'ro',
  isa => 'ArrayRef[Pod::Weaver::Role::Plugin]',
  required => 1,
  lazy     => 1,
  init_arg => undef,
  default  => sub { [] },
);

sub plugins_with {
  my ($self, $role) = @_;

  $role =~ s/^-/Pod::Weaver::Role::/;
  my $plugins = $self->plugins->grep(sub { $_->does($role) });

  return $plugins;
}

sub weave_document {
  my ($self, $input) = @_;

  my $document = Pod::Elemental::Document->new;
  return $document;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
