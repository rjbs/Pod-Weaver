package Pod::Weaver::Plugin::SingleEncoding;
use Moose;
with(
  'Pod::Weaver::Role::Dialect',
  'Pod::Weaver::Role::Finalizer',
);
# ABSTRACT: ensure that there is exactly one =encoding of known value

use namespace::autoclean;
use Moose::Autobox;

use Pod::Elemental::Selectors -all;

=head1 OVERVIEW

I dunno, man, I just wrote this thing.

=cut

has encoding => (
  is  => 'ro',
  isa => 'Str',
  default => 'UTF-8',
);

sub translate_dialect {
  my ($self, $document) = @_;

  my $childs = $document->children;
  my $is_enc = s_command([ qw(encoding) ]);
  my $want   = $self->encoding;

  for (reverse 0 .. $#$childs) {
    next unless $is_enc->( $childs->[ $_ ] );
    print "! $_\n";
    my $have = $childs->[$_]->content;
    $have =~ s/\s+\z//;

    confess "expected only $want encoding but found $have"
      unless lc $have eq lc $want;

    splice @$childs, $_, 1;
  }

  return;
}

sub finalize_document {
  my ($self, $document, $input) = @_;

  my $encoding = Pod::Elemental::Element::Pod5::Command->new({
    command => 'encoding',
    content => $self->encoding,
  });

  my $childs = $document->children;
  my $is_pod = s_command([ qw(pod) ]); # ??
  for (0 .. $#$childs) {
    next if $is_pod->( $childs->[ $_ ] );
    splice @$childs, $_, 0, $encoding;
    last;
  }

  return;
}

no Moose;
1;
