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
must be given.  It will look for the first package declaration, and for a
comment in this form:

  # ABSTRACT: a document for some

=cut

use Pod::Elemental::Element::Pod5::Command;
use Pod::Elemental::Element::Pod5::Ordinary;
use Pod::Elemental::Element::Nested;

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless my $ppi_document = $input->{ppi_document};
  my $pkg_node = $ppi_document->find_first('PPI::Statement::Package');

  my $filename = 'file'; # $arg->{filename}

  Carp::croak sprintf "couldn't find package declaration in %s", $filename
    unless $pkg_node;

  my $package = $pkg_node->namespace;

  my ($abstract)
    = $ppi_document->serialize =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

  $self->log([ "couldn't find abstract in %s", $filename ]) unless $abstract;
 
  my $name = $package;
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
