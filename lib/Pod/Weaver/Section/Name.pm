package Pod::Weaver::Section::Name;
# ABSTRACT: add a NAME section with abstract (for your Perl module)

use Moose;
with 'Pod::Weaver::Role::Section';
with 'Pod::Weaver::Role::StringFromComment';

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

sub _get_docname_via_statement {
  my ($self, $ppi_document) = @_;

  my $pkg_node = $ppi_document->find_first('PPI::Statement::Package');
  return unless $pkg_node;
  return $pkg_node->namespace;
}

sub _get_docname_via_comment {
  my ($self, $ppi_document) = @_;

  return $self->_extract_comment_content($ppi_document, 'PODNAME');
}

sub _get_docname {
  my ($self, $input) = @_;

  my $ppi_document = $input->{ppi_document};

  my $docname = $self->_get_docname_via_comment($ppi_document)
             || $self->_get_docname_via_statement($ppi_document);

  return $docname;
}

sub _get_abstract {
  my ($self, $input) = @_;

  my $comment = $self->_extract_comment_content($input->{ppi_document}, 'ABSTRACT');

  return $comment if $comment;

  # If that failed, fall back to searching the whole document
  my ($abstract)
    = $input->{ppi_document}->serialize =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

  return $abstract;
}

sub weave_section {
  my ($self, $document, $input) = @_;

  my $filename = $input->{filename} || 'file';

  my $docname  = $self->_get_docname($input);
  my $abstract = $self->_get_abstract($input);

  Carp::croak sprintf "couldn't determine document name for %s\nAdd something like this to %s:\n# PODNAME: bobby_tables.pl", $filename, $filename
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

__PACKAGE__->meta->make_immutable;
1;
