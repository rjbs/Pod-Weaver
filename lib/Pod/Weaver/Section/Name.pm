package Pod::Weaver::Section::Name;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: add a NAME section with abstract (for your Perl module)

use Moose::Autobox;

=head1 OVERVIEW

This section plugin will produce a hunk of Pod giving the name of the document
as well as an abstract, like this:

  =head1 NAME

  Some::Document - a document for some

It will determine the name and abstract by inspecting the C<ppi_document> which
must be given.  It looks for comments in the form:


  # ABSTRACT: a document for some
  # PODNAME: Some::Package::Name

If no C<PODNAME> comment is present, but a package declaration can be found,
the package name will be used as the document name.

=cut

use Pod::Elemental::Element::Pod5::Command;
use Pod::Elemental::Element::Pod5::Ordinary;
use Pod::Elemental::Element::Nested;

sub weave_section {
  my ($self, $document, $input) = @_;

  my $filename = $input->{filename} || 'file';

  my $docname  = $self->get_docname($input);
  my $abstract = $self->get_abstract($input);

  Carp::croak sprintf "couldn't determine document name for %s", $filename
    unless $docname;

  $self->log([ "couldn't find abstract in %s", $filename ]) unless $abstract;

  my $name = $docname;
  $name .= " - $abstract" if $abstract;

  my $name_para = Pod::Elemental::Element::Nested->new({
    command  => 'head1',
    content  => 'NAME',
    children => [
      Pod::Elemental::Element::Pod5::Ordinary->new({ content => $name }),
    ],
  });

  $document->children->push($name_para);
}

1;
