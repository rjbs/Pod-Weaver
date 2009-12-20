package Pod::Weaver::Plugin::Transformer;
use Moose;
with 'Pod::Weaver::Role::Dialect';
# ABSTRACT: apply arbitrary transformers

use namespace::autoclean;
use Moose::Autobox;

use List::MoreUtils qw(part);
use String::RewritePrefix;

=head1 OVERVIEW

=cut

has transformer => (is => 'ro', required => 1);

sub BUILDARGS {
  my ($class, @arg) = @_;
  my %copy = ref $arg[0] ? %{$arg[0]} : @arg;

  my @part = part { /\A\./ ? 0 : 1 } keys %copy;

  my %class_args = map { s/\A\.//; $_ => $copy{ ".$_" } } @{ $part[0] };
  my %xform_args = map {           $_ => $copy{ $_ }    } @{ $part[1] };

  my $xform_class = String::RewritePrefix->rewrite(
    { '' => 'Pod::Elemental::Transformer::', '=' => '' },
    delete $class_args{transformer},
  );

  Class::MOP::load_class($xform_class);

  my $plugin_name = delete $xform_args{plugin_name};
  my $weaver      = delete $xform_args{weaver};

  my $xform = $xform_class->new(\%xform_args);

  return {
    %class_args,
    plugin_name => $plugin_name,
    weaver      => $weaver,
    transformer => $xform,
  }
}

sub translate_dialect {
  my ($self, $pod_document) = @_;

  $self->transformer->transform_node( $pod_document );
}

1;

__END__
=pod

=head1 NAME

Pod::Weaver::Plugin::WikiDoc - allow wikidoc-format regions to be translated during dialect phase

=head1 VERSION

version 0.093001

=head1 OVERVIEW

This plugin is an exceedingly thin wrapper around
L<Pod::Elemental::Transformer::WikiDoc>.  When you load this plugin, then
C<=begin> and C<=for> regions with the C<wikidoc> format will be translated to
standard Pod5 before further weaving continues.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Pod::Weaver::Plugin::WikiDoc;
our $VERSION = '0.093001';


use Moose;
with 'Pod::Weaver::Role::Dialect';
# ABSTRACT: allow wikidoc-format regions to be translated during dialect phase


use namespace::autoclean;

use Pod::Elemental::Transformer::WikiDoc;

sub translate_dialect {
  my ($self, $pod_document) = @_;

  Pod::Elemental::Transformer::WikiDoc->new->transform_node($pod_document);
}

1;

__END__
=pod

=head1 NAME

Pod::Weaver::Plugin::WikiDoc - allow wikidoc-format regions to be translated during dialect phase

=head1 VERSION

version 0.093001

=head1 OVERVIEW

This plugin is an exceedingly thin wrapper around
L<Pod::Elemental::Transformer::WikiDoc>.  When you load this plugin, then
C<=begin> and C<=for> regions with the C<wikidoc> format will be translated to
standard Pod5 before further weaving continues.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

