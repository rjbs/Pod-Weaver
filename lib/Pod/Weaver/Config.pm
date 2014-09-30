package Pod::Weaver::Config;

use Moose::Role;
# ABSTRACT: stored configuration loader role

use Config::MVP 2;

use Pod::Weaver::Config::Assembler;

=head1 DESCRIPTION

The config role provides some helpers for writing a configuration loader using
the L<Config::MVP|Config::MVP> system to load and validate its configuration.

=attr assembler

The L<assembler> attribute must be a Config::MVP::Assembler, has a sensible
default that will handle the standard needs of a config loader.  Namely, it
will be pre-loaded with a starting section for root configuration.

=cut

sub build_assembler {
  my $assembler = Pod::Weaver::Config::Assembler->new;

  my $root = $assembler->section_class->new({
    name    => '_',
  });

  $assembler->sequence->add_section($root);

  return $assembler;
}

no Moose::Role;
1;
