package Template::Caribou::Tags::HTML;
BEGIN {
  $Template::Caribou::Tags::HTML::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Tags::HTML::VERSION = '0.1.0';
}

use strict;
use warnings;

use Template::Caribou::Utils;

use parent 'Exporter';

our @EXPORT = qw/ p html head  h1 body emphasis div style title /;


sub p(&) { render_tag( 'p', shift ) }
sub html(&) { render_tag( 'html', shift ) }
sub head(&) { render_tag( 'head', shift ) }
sub body(&) { render_tag( 'body', shift ) }
sub h1(&) { render_tag( 'h1', shift ) }
sub emphasis(&) { render_tag( 'em', shift ) }
sub div(&) { render_tag( 'div', shift ) }
sub style(&) { render_tag( 'style', shift ) }
sub title(&) { render_tag( 'title', shift ) }

1;

__END__
=pod

=head1 NAME

Template::Caribou::Tags::HTML

=head1 VERSION

version 0.1.0

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

