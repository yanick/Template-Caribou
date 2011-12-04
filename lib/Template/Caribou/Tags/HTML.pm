package Template::Caribou::Tags::HTML;

use strict;
use warnings;

use Template::Caribou::Utils;

use parent 'Exporter';

our @EXPORT = qw/ p html head  h1 body emphasis /;


sub p(&) { render_tag( 'p', undef, shift ) }
sub html(&) { render_tag( 'html', undef, shift ) }
sub head(&) { render_tag( 'head', undef, shift ) }
sub body(&) { render_tag( 'body', undef, shift ) }
sub h1(&) { render_tag( 'h1', undef, shift ) }
sub emphasis(&) { render_tag( 'em', undef, shift ) }

1;
