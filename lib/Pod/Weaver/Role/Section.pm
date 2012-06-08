package Pod::Weaver::Role::Section;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: a plugin that will get a section into a woven document

=head1 IMPLEMENTING

This role is used by plugins that will append sections to the output document.
They must provide a method, C<weave_section> which will be invoked like this:

  $section_plugin->weave_section($output_document, \%input);

They are expected to append their output to the output document, but they are
free to behave differently if it's needed to do something really cool.

=cut

requires 'weave_section';

sub _extract_comment_content {
  my ($self, $ppi_document, $regex) = @_;

  my $content;
  my $finder = sub {
    my $node = $_[1];
    return 0 unless $node->isa('PPI::Token::Comment');
    if ( $node->content =~ $regex ) {
      $content = $1;
      return 1;
    }
    return 0;
  };

  $ppi_document->find_first($finder);

  return $content;
}

sub _get_docname_via_statement {
  my ($self, $ppi_document) = @_;

  my $pkg_node = $ppi_document->find_first('PPI::Statement::Package');
  return unless $pkg_node;
  return $pkg_node->namespace;
}

sub _get_docname_via_class_decl {
  my ($self, $ppi_document) = @_;

  my $word_node = $ppi_document->find_first(sub {
      $_[1]->isa('PPI::Token::Word')
      and $_[1]->content eq 'class'
      and $_[1]->snext_sibling
      and $_[1]->snext_sibling->isa('PPI::Token::Word')
  });
  return unless $word_node;
  return $word_node->snext_sibling->content;
}

sub _get_docname_via_comment {
  my ($self, $ppi_document) = @_;

  return $self->_extract_comment_content(
    $ppi_document,
    qr/^\s*#+\s*PODNAME:\s*(.+)$/m,
  );
}

sub get_docname {
  my ($self, $input) = @_;

  return unless exists $input->{ppi_document};
  my $ppi_document = $input->{ppi_document};

  my $docname = $self->_get_docname_via_comment($ppi_document)
             || $self->_get_docname_via_statement($ppi_document)
             || $self->_get_docname_via_class_decl($ppi_document);

  return $docname;
}

sub get_abstract {
  my ($self, $input) = @_;

  my $comment = $self->_extract_comment_content(
    $input->{ppi_document},
    qr/^\s*#+\s*ABSTRACT:\s*(.+)$/m,
  );

  return $comment if $comment;

  # If that failed, fall back to searching the whole document
  my ($abstract)
    = $input->{ppi_document}->serialize =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

  return $abstract;
}

no Moose::Role;
1;
