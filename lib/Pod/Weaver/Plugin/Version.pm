  if ($arg->{version} and not _h1(VERSION => @pod)) {
    unshift @pod, (
      { type => 'command', command => 'head1', content => "VERSION\n"  },
      { type => 'text',   
        content => sprintf "version %s\n", $arg->{version} }
    );
  }
