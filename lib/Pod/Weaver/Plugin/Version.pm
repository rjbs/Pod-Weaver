package Pod::Weaver::Plugin::Version;
use Moose;
with 'Pod::Weaver::Role::Plugin';

#  if ($arg->{version} and not _h1(VERSION => @pod)) {
#    unshift @pod, (
#      { type => 'command', command => 'head1', content => "VERSION\n"  },
#      { type => 'text',   
#        content => sprintf "version %s\n", $arg->{version} }
#    );
#  }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
