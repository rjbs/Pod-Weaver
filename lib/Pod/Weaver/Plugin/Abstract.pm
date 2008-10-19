  unless (_h1(NAME => @pod)) {
    Carp::croak "couldn't find package declaration in document"
      unless my $pkg_node = $doc->find_first('PPI::Statement::Package');
    my $package = $pkg_node->namespace;

    $self->log("couldn't find abstract in $arg->{filename}")
      unless my ($abstract) = $podless_doc_str =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

    my $name = $package;
    $name .= " - $abstract" if $abstract;

    unshift @pod, (
      { type => 'command', command => 'head1', content => "NAME\n"  },
      { type => 'text',                        content => "$name\n" },
    );
  }
