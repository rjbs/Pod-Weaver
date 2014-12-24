use strict;
use warnings;

use Test::More;

use PPI;

use Pod::Elemental;
use Pod::Weaver;

is( woven( configer( 0 ) ), 0, "Doesn't throw exception for nonrequired region" );

is( woven( configer( 1 ) ), 1, "Properly throws exception for required region" );

sub configer {
  my $required = shift;

  # TODO Hmpf, is there an easier way for this? --APOCAL
  my $assembler = Pod::Weaver::Config::Assembler->new;
  $assembler->sequence->add_section( $assembler->section_class->new({ name => '_' }) );
  $assembler->change_section('@Default');
  $assembler->change_section('Region', 'FOOBAZ');
  $assembler->add_value( 'required' => $required );
  return Pod::Weaver->new_from_config_sequence( $assembler->sequence );
}

my $perl_document;
sub woven {
  my $weaver = shift;

  my $in_pod   = do { local $/; open my $fh, '<:raw:bytes', 't/eg/basic.in.pod'; <$fh> };
  my $document = Pod::Elemental->read_string($in_pod);

  $perl_document = do { local $/; <DATA> } if ! defined $perl_document;
  my $ppi_document  = PPI::Document->new(\$perl_document);

  require Software::License::Artistic_1_0;
  eval {
    my $woven = $weaver->weave_document({
      pod_document => $document,
      ppi_document => $ppi_document,

      version  => '1.012078',
      authors  => [
        'Ricardo Signes <rjbs@example.com>',
        'Molly Millions <sshears@orbit.tash>',
      ],
      license  => Software::License::Artistic_1_0->new({
        holder => 'Ricardo Signes',
        year   => 1999,
      }),
    });
  };

  return $@ ? 1 : 0;
}

done_testing;

__DATA__

package Module::Name;
# ABSTRACT: abstract text

my $this = 'a test';
