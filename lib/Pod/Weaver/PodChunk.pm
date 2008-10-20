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

__PACKAGE__->meta->make_immutable;
no Moose;
1;
