package Pod::Weaver::PodChunk;
use Moose;
use Moose::Autobox;

has type    => (is => 'ro', isa => 'Str', required => 1);
has content => (is => 'ro', isa => 'Str', required => 1);
has command => (is => 'ro', isa => 'Str', required => 0);

has children => (
  is   => 'ro',
  isa  => 'ArrayRef[Pod::Weaver::PodChunk]',
  auto_deref => 1,
  required   => 1,
  default    => sub { [] },
);

sub as_hash {
  my ($self) = @_;

  my $hash = {
    type    => $self->type,
    content => $self->content,
  };

  $hash->{command}  = $self->command if defined $self->command;
  $hash->{children} = $self->children->map(sub { $_->as_hash })
    if $self->children->length;;

  return $hash;
}

sub as_string {
  my ($self) = @_;

  my @para;

  if ($self->type eq 'command') {
    push @para, sprintf '=%s %s', $self->command, $self->content;
    if ($self->children->length) {
      push @para, $self->children->map(sub { $_->as_string })->flatten;
    }

    push @para, "=back\n" if $self->command eq 'over';
    push @para, ('=end ' . $self->content) if $self->command eq 'begin';
  } else {
    push @para, $self->content;
  }

  return join "\n", @para;
}

sub as_debug_string {
  my ($self) = @_;

  my @para;

  if ($self->type eq 'command') {
    push @para, sprintf '=%s %s', $self->command, $self->content;
    if ($self->children->length) {
      my @sub = $self->children->map(sub { $_->as_debug_string })->flatten;
      s/^/  /gm for @sub;
      push @para, @sub;
    }

    push @para, "=back\n" if $self->command eq 'over';
    push @para, ('=end ' . $self->content) if $self->command eq 'begin';
  } else {
    push @para, $self->content;
  }

  return join "", @para;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
