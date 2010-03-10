package Pod::Weaver::Role::Plugin;
use Moose::Role;
# ABSTRACT: a Pod::Weaver plugin

use Params::Util qw(_HASHLIKE);

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
);

for my $method (qw(log log_debug log_fatal)) {
  Sub::Install::install_sub({
    code => sub {
      my ($self, @rest) = @_;
      my $arg = _HASHLIKE($rest[0]) ? (shift @rest) : {};
      local $arg->{prefix} = '[' . $self->plugin_name . '] '
                           . (defined $arg->{prefix} ? $arg->{prefix} : '');

      $self->weaver->logger->$method($arg, @rest);
    },
    as   => $method,
  });
}

1;
