package Pod::Weaver;
use Moose;
# ABSTRACT: do horrible things to POD, producing better docs

use List::MoreUtils qw(any);
use Moose::Autobox;
use Pod::Weaver::Parser;
use String::Flogger;

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
    Pod::Weaver::_Logger;
  sub log { printf "%s\n", String::Flogger->($_[1]) }
}

has logger => (
  lazy    => 1,
  default => sub { bless {} => 'Pod::Weaver::_Logger' },
  handles => [ qw(log) ]
);

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

  my $parser = 'Pod::Weaver::Parser';

  my $podless_doc_str = $doc->serialize;

  if ($parser->new->read_string($podless_doc_str)->length) {
    $self->log(
      sprintf "can't invoke %s on %s: there is POD inside string literals",
        'Pod::Weaver', $arg->{filename} # XXX
    );
    return;
  }

  my @pod = $parser->new->read_string(join "\n", @pod_tokens)->flatten;

  # version was here

  # abstract was here

  # methods and attributes were here

  # author was here

  # license was here

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

  $content = $end ? "$podless_doc_str\n\n$newpod\n\n$end"
                  : "$podless_doc_str\n__END__\n$newpod\n";

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

__PACKAGE__->meta->make_immutable;
no Moose;
1;
