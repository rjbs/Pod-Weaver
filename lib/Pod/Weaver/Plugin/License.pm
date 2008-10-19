  if ($arg->{license} and ! (_h1(COPYRIGHT => @pod) or _h1(LICENSE => @pod))) {
    push @pod, (
      { type => 'command', command => 'head1',
        content => "COPYRIGHT AND LICENSE\n" },
      { type => 'text', content => $arg->{license}->notice }
    );
  }
