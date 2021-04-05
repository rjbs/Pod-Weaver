#!/usr/bin/env perl
use utf8;

## Copyright (C) 2017 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

use Test::More;

use Test::DZil;
use Test::Fatal;

my @tests = (
  {
    name => "default values, title on plugin name",
    config => <<'ENDCONFIG',
[GenerateSection / Header Title]
ENDCONFIG
    expected => <<'ENDPOD',
=head1 Header Title

=cut
ENDPOD
  },
  {
    name => "default values, title as parameter",
    config => <<'ENDCONFIG',
[GenerateSection]
title = Header Title
ENDCONFIG
    expected => <<'ENDPOD',
=head1 Header Title

=cut
ENDPOD
  },
  {
    name => "default values with template",
    config => <<'ENDCONFIG',
[GenerateSection]
title = Header Title
text = This is package {{$name}} v{{$version}}
ENDCONFIG
    expected => <<'ENDPOD',
=head1 Header Title

This is package Foo-Bar v0.010

=cut
ENDPOD
 },
  {
    name => "template for resources in metadata",
    config => <<'ENDCONFIG',
[GenerateSection]
title = Header Title
text = Name {{$name}}
text = v{{$version}}
text = Homepage {{$homepage}}
text = repo web {{$repository_web}}
text = repo url {{$repository_url}}
text = bugtracker url {{$bugtracker_web}}
text = bugtracker email {{$bugtracker_email}}
ENDCONFIG
    dzil_options => [
      [MetaResources => {
        'homepage' => 'https://gnu.org/pro',
        'bugtracker.web' => 'https://not-savannah-please.gnu.org/bugs/',
        'bugtracker.mailto' => 'bug-project@rt.cpan.org',
        'repository.url' => 'https://there.com/dude/project',
        'repository.web' => 'https://hg.gnu.org/hgweb/pro',
      }],
    ],
    expected => <<'ENDPOD',
=head1 Header Title

Name Foo-Bar
v0\.010
Homepage https://gnu\.org/pro
repo web https://hg\.gnu\.org/hgweb/pro
repo url https://there\.com/dude/project
bugtracker url https://not-savannah-please\.gnu\.org/bugs/
bugtracker email bug-project@rt\.cpan\.org

=cut
ENDPOD
 },
  {
    name => "disabling template",
    config => <<'ENDCONFIG',
[GenerateSection]
title = Header Title
is_template = 0
text = This is package {{$name}} v{{$version}}
ENDCONFIG
    expected => << 'ENDPOD',
=head1 Header Title

This is package \{\{\$name}} v\{\{\$version}}

=cut
ENDPOD
 },
  {
    name => "section as header level 2",
    config => <<'ENDCONFIG',
[GenerateSection]
title = The big lock-out
head = 2
text = I ate all your bees.
ENDCONFIG
    expected => <<'ENDPOD',
=head2 The big lock-out

I ate all your bees.

=cut
ENDPOD
 },
  {
    name => "just text, no header",
    config => <<'ENDCONFIG',
[GenerateSection]
title = The big lock-out
head = 0
text = I ate all your bees.
ENDCONFIG
    expected => <<'ENDPOD',

I ate all your bees.

ENDPOD
 },
  {
    name => "multiline text section",
    config => <<'ENDCONFIG',
[GenerateSection]
title = Elephants and Hens
head = 2
text = Here is the elephant; he's happy with his balloon.
text = Oh no! It's gone! Where is it? It's not behind the rhino
text = Look in the alligator's mouth,
text = It's not there either!
text = Ohhhh the Monkey's got it in the tree! He brings it back
text = They all drink lemonade.
text = The End!
ENDCONFIG
    expected => << 'ENDPOD',
=head2 Elephants and Hens

Here is the elephant; he's happy with his balloon\.
Oh no\! It's gone\! Where is it\? It's not behind the rhino
Look in the alligator's mouth,
It's not there either\!
Ohhhh the Monkey's got it in the tree\! He brings it back
They all drink lemonade\.
The End\!

=cut
ENDPOD
 },
  {
    name => "empty lines on text",
    config => <<'ENDCONFIG',
[GenerateSection / Header Title]
text = This is life!
text =
text = We suffer, and slave, and expire.
text = That's it.
ENDCONFIG
    expected => <<'ENDPOD',
=head1 Header Title

This is life\!

We suffer, and slave, and expire.
That's it.

=cut
ENDPOD
  },
);

my $module_text = <<'END';
package Foo;
1;
END

foreach my $test (@tests)
  {
    my $dzil_options = defined ($test->{dzil_options}) ?
                         $test->{dzil_options} : [];
    my $dzil_ini = simple_ini (
      {name => 'Foo-Bar', version => '0.010'},
      'GatherDir', # needed for the build to remain after build
      'PodWeaver', # this is a pod weaver plugin
      @$dzil_options,
    );

    subtest $test->{name} => sub
    {
      my $tzil = Test::DZil->Builder->from_config (
        {dist_root => 'does-not-exist'},
        {
          add_files => {
            "source/dist.ini" => $dzil_ini,
            "source/lib/Foo.pm" => $module_text,
            "source/Changes" => "",
            "source/weaver.ini" => $test->{config},
          },
        }
      );

      $tzil->chrome->logger->set_debug (1);

      is (exception { $tzil->build },undef, 'build completes');
      like ($tzil->slurp_file ("build/lib/Foo.pm"),
            qr/$test->{expected}/,
            'correct section generated');
    }
  }

done_testing;
