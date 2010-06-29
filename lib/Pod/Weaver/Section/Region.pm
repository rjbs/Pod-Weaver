package Pod::Weaver::Section::Region;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: find a region and put its contents in place where desired

use Moose::Autobox;

use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Types qw(FormatName);

has required => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

has region_name => (
  is   => 'ro',
  isa  => FormatName,
  lazy => 1,
  required => 1,
  default  => sub { $_[0]->plugin_name },
);

=attr allow_nonpod

A boolean value specifying whether nonpod regions are allowed or not. Defaults to false.

=cut

has allow_nonpod => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

=attr flatten

A boolean value specifying whether the region's contents should be flattened or not. Defaults to true.

=cut

has flatten => (
  is  => 'ro',
  isa => 'Bool',
  default => 1,
);

sub weave_section {
  my ($self, $document, $input) = @_;

  my @to_insert;

  my $idc = $input->{pod_document}->children;
  IDX: for (my $i = 0; $i < $idc->length; $i++) {
    next unless my $para = $idc->[ $i ];
    next unless $para->isa('Pod::Elemental::Element::Pod5::Region')
         and    $para->format_name eq $self->region_name;
    next if     !$self->allow_nonpod and !$para->is_pod;

    if ( $self->flatten ) {
      push @to_insert, $para->children->flatten;
    } else {
      push @to_insert, $para;
    }

    splice @$idc, $i, 1;

    redo IDX;
  }

  $document->children->push(@to_insert);
}

no Moose;
1;
