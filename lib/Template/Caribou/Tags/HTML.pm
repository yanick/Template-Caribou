package Template::Caribou::Tags::HTML;

use strict;
use warnings;

use Template::Caribou::Utils;

BEGIN {
    @Template::Caribou::Tags::HTML::TAGS =  qw/
        p html head h1 h2 h3 h4 h5 h6 body emphasis div
        style title span li ol ul i b bold a form input
        label link img section article
        table thead tbody table_row th td
    /;
}

use Template::Caribou::Tags
    'render_tag',
    'attr',
    mytag => { -as => 'table_row', name => 'tr' },
    map { ( mytag => { -as => $_, name => $_ } ) }
        grep { !/table_row/ }
        @Template::Caribou::Tags::HTML::TAGS;

use Sub::Exporter -setup => {
    exports => [
        @Template::Caribou::Tags::HTML::TAGS
    ],
    groups => { default => ':all' },
};

1;
