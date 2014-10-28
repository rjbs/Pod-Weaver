package Pod::Weaver::Section::Region;
# ABSTRACT: find a region and put its contents in place where desired

use Moose;
with 'Pod::Weaver::Role::Section';

use Moose::Autobox;

=head1 OVERVIEW

This section will find and include a located hunk of Pod.  In general, it will
find a region with the specified name.

In other words, if your configuration include:

  [Region]
  region_name = myfoo

...then this weaver will look for "=begin myfoo" ( and "=for myfoo" and... ) and include
it at the appropriate location in your output.

Since you'll probably want to use Region several times, and that will require
giving each use a unique name, you can omit C<region_name> if you provide a
plugin name, and it will default to the plugin name.  In other words, the
configuration above could be specified just as:

  [Region / myfoo]

If the C<required> attribute is given, and true, then an exception will be
raised if this region can't be found.

=cut

use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Types qw(FormatName);

=attr required

A boolean value specifying whether this region is required to be present or not. Defaults
to false.

If it's enabled and the region can't be found an exception will be raised.

=cut

has required => (
  is  => 'ro',
  isa => 'Bool',
  default => 0,
);

=attr region_name

The name of this region. Defaults to the plugin name.

=cut

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

  confess "Couldn't find required Region for " . $self->region_name . " in file "
    . (defined $input->{filename} ? $input->{filename} : '') if $self->required and not @to_insert;

  $document->children->push(@to_insert);
}

__PACKAGE__->meta->make_immutable;
1;
