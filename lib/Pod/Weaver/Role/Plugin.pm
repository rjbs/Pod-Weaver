package Pod::Weaver::Role::Plugin;
use Moose::Role;
# ABSTRACT: a Pod::Weaver plugin

use namespace::autoclean;

=head1 IMPLEMENTING

This is the most basic role that all plugins must perform.

=attr plugin_name

This name must be unique among all other plugins loaded into a weaver.  In
general, this will be set up by the configuration reader.

=cut

has plugin_name => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

=attr weaver

This is the Pod::Weaver object into which the plugin was loaded.  In general,
this will be set up when the weaver is instantiated from config.

=cut

has weaver => (
  is  => 'ro',
  isa => 'Pod::Weaver',
  required => 1,
  weak_ref => 1,
  handles  => [ qw(log) ],
);

for my $method (qw(log log_debug log_fatal)) {
  Sub::Install::install_sub({
    code => sub {
      my $self = shift;
      $self->weaver->$method($self->plugin_name, @_); },
    as   => $method,
  });
}

1;
