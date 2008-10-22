package Pod::Weaver::Weaver::License;
use Moose;
with 'Pod::Weaver::Role::Weaver';

use Moose::Autobox;

sub weave {
  my ($self) = @_;
# if ($arg->{license} and ! (_h1(COPYRIGHT => @pod) or _h1(LICENSE => @pod))) {
#   push @pod, (
#     { type => 'command', command => 'head1',
#       content => "COPYRIGHT AND LICENSE\n" },
#     { type => 'text', content => $arg->{license}->notice }
#   );
# }

  require Software::License::Perl_5;
  my $license = Software::License::Perl_5->new({
    year   => 2008,
    holder => 'rjbs',
  });

  my $notice = $license->notice;
  chomp $notice;

  $self->weaver->output_pod->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => 'COPYRIGHT AND LICENSE',
      children => [
        Pod::Elemental::Element::Text->new({
          type    => 'text',
          content => $notice,
        }),
      ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
