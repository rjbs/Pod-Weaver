package Pod::Weaver::Section::Region;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: find a region and put its contents in place where desired

use Moose::Autobox;

use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Selectors -all;

has required => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

# has format_name; must be is_pod

sub weave_section {
  my ($self, $document, $input) = @_;

  # find all regions of our format name
  # flatten their children
  # push onto output document
}

no Moose;
1;
