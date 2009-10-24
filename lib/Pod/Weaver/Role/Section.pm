package Pod::Weaver::Role::Section;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: a plugin that will get a section into a woven document

=head1 IMPLEMENTING

This role is used by plugins that will append sections to the output document.
They must provide a method, C<weave_section> which will be invoked like this:

  $section_plugin->weave_section($output_document, \%input);

They are expected to append their output to the output document, but they are
free to behave differently if it's needed to do something really cool.

=cut

requires 'weave_section';

no Moose::Role;
1;
