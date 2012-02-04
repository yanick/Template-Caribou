package Template::Caribou::Tags::HTML;

use strict;
use warnings;

use Template::Caribou::Utils;

use parent 'Exporter';

our @EXPORT = qw/ p html head  h1 body emphasis div style /;


sub p(&) { render_tag( 'p', shift ) }
sub html(&) { render_tag( 'html', shift ) }
sub head(&) { render_tag( 'head', shift ) }
sub body(&) { render_tag( 'body', shift ) }
sub h1(&) { render_tag( 'h1', shift ) }
sub emphasis(&) { render_tag( 'em', shift ) }
sub div(&) { render_tag( 'div', shift ) }
sub style(&) { render_tag( 'style', shift ) }

1;
