package Pod::Weaver;
# ABSTRACT: do horrible things to POD, producing better docs
use Moose::Autobox;
use List::MoreUtils qw(any);

=head1 WARNING

This code is really, really sketchy.  It's crude and brutal and will probably
break whatever it is you were trying to do.

Eventually, this code will be really awesome.  I hope.  It will probably
provide an interface to something more cool and sophisticated.  Until then,
don't expect it to do anything but bring sorrow to you and your people.

=head1 DESCRIPTION

Pod::Weaver is a work in progress, which rips apart your kinda-POD and
reconstructs it as boring old real POD.

=cut

{
  package
    Pod::Weaver::_Eventual;
  use Pod::Eventual::Simple;
  our @ISA = 'Pod::Eventual::Simple';

  sub handle_nonpod {}
}

sub _h1 {
  my $name = shift;
  any { $_->{type} eq 'command' and $_->{content} =~ /^\Q$name$/m } @_;
}

sub _events_to_string {
  my ($self, $events) = @_;
  my $str = "\n=pod\n\n";

  EVENT: for my $event (@$events) {
    if ($event->{type} eq 'verbatim') {
      $event->{content} =~ s/^/  /mg;
      $event->{type} = 'text';
    }

    if ($event->{type} eq 'text') {
      $str .= "$event->{content}\n";
      next EVENT;
    }

    $str .= "=$event->{command} $event->{content}\n";
  }

  return $str;
}

=method munge_pod_string

  my $new_content = Pod::Weaver->munge_pod_string($string, \%arg);

Right now, this is the only method.  You feed it a string containing a
POD-riddled document and it returns a woven form.  Right now, you can't really
do much configuration of the loom.

Valid arguments are:

  filename - the name of the document file being rewritten (for errors)
  version  - the version of the document
  authors  - an arrayref of document authors (provided as strings)
  license  - the license of the document (a Software::License object)

=cut

sub munge_pod_string {
  my ($self, $content, $arg) = @_;
  $arg ||= {};
  $arg->{authors}  ||= [];
  $arg->{filename} ||= 'document';

  require PPI;
  my $doc = PPI::Document->new(\$content);
  my @pod_tokens = map {"$_"} @{ $doc->find('PPI::Token::Pod') || [] };
  $doc->prune('PPI::Token::Pod');

  if (@{ $doc->find('PPI::Token::HereDoc') || [] }) {
    $self->log(
      sprintf "can't invoke %s on %s: PPI can't munge code with here-docs",
        'Pod::Weaver', $arg->{filename} # XXX
    );
    return;
  }

  my $pe = 'Pod::Weaver::_Eventual';

  if ($pe->new->read_string("$doc")->length) {
    $self->log(
      sprintf "can't invoke %s on %s: there is POD inside string literals",
        'Pod::Weaver', $arg->{filename} # XXX
    );
    return;
  }

  my @pod = $pe->new->read_string(join "\n", @pod_tokens)->flatten;

  if ($arg->{version} and not _h1(VERSION => @pod)) {
    unshift @pod, (
      { type => 'command', command => 'head1', content => "VERSION\n"  },
      { type => 'text',   
        content => sprintf "version %s\n", $arg->{version} }
    );
  }

  unless (_h1(NAME => @pod)) {
    Carp::croak "couldn't find package declaration in document"
      unless my $pkg_node = $doc->find_first('PPI::Statement::Package');
    my $package = $pkg_node->namespace;

    $self->log("couldn't find abstract in $arg->{filename}")
      unless my ($abstract) = $doc =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

    my $name = $package;
    $name .= " - $abstract" if $abstract;

    unshift @pod, (
      { type => 'command', command => 'head1', content => "NAME\n"  },
      { type => 'text',                        content => "$name\n" },
    );
  }

  my (@methods, $in_method);

  $self->_regroup($_->[0] => $_->[1] => \@pod)
    for ( [ attr => 'ATTRIBUTES' ], [ method => 'METHODS' ] );

  if (
    $arg->{authors}->length
    and ! (_h1(AUTHOR => @pod) or _h1(AUTHORS => @pod))
  ) {
    my $name = $arg->{authors}->length > 1 ? 'AUTHORS' : 'AUTHOR';

    push @pod, (
      { type => 'command',  command => 'head1', content => "$name\n" },
      { type => 'verbatim', content => $arg->{authors}->join("\n") . "\n"
      }
    );
  }

  if ($arg->{license} and ! (_h1(COPYRIGHT => @pod) or _h1(LICENSE => @pod))) {
    push @pod, (
      { type => 'command', command => 'head1',
        content => "COPYRIGHT AND LICENSE\n" },
      { type => 'text', content => $arg->{license}->notice }
    );
  }

  @pod = grep { $_->{type} ne 'command' or $_->{command} ne 'cut' } @pod;
  push @pod, { type => 'command', command => 'cut', content => "\n" };

  my $newpod = $self->_events_to_string(\@pod);

  my $end = do {
    my $end_elem = $doc->find('PPI::Statement::Data')
                || $doc->find('PPI::Statement::End');
    join q{}, @{ $end_elem || [] };
  };

  $doc->prune('PPI::Statement::End');
  $doc->prune('PPI::Statement::Data');

  $content = $end ? "$doc\n\n$newpod\n\n$end" : "$doc\n__END__\n$newpod\n";

  return $content;
}

sub _regroup {
  my ($self, $cmd, $header, $pod) = @_;

  my @items;
  my $in_item;

  EVENT: for (my $i = 0; $i < @$pod; $i++) {
    my $event = $pod->[$i];

    if ($event->{type} eq 'command' and $event->{command} eq $cmd) {
      $in_item = 1;
      push @items, splice @$pod, $i--, 1;
      next EVENT;
    }

    if (
      $event->{type} eq 'command'
      and $event->{command} !~ /^(?:over|item|back|head[3456])$/
    ) {
      $in_item = 0;
      next EVENT;
    }

    push @items, splice @$pod, $i--, 1 if $in_item;
  }
      
  if (@items) {
    unless (_h1($header => @$pod)) {
      push @$pod, {
        type    => 'command',
        command => 'head1',
        content => "$header\n",
      };
    }

    $_->{command} = 'head2'
      for grep { ($_->{command}||'') eq $cmd } @items;

    push @$pod, @items;
  }
}

1;
