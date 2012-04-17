package Template::Caribou::Tags::HTML;

use strict;
use warnings;

use Template::Caribou::Utils;

BEGIN {
    @Template::Caribou::Tags::HTML::TAGS =  qw/
        p html head h1 h2 h3 h4 h5 h6 body emphasis div
        style title span li ol ul 
    /;
}

use Template::Caribou::Tags
    map { ( mytag => { -as => $_, tag => $_ } ) }
        @Template::Caribou::Tags::HTML::TAGS;

use Sub::Exporter -setup => {
    exports => [
        qw/ css anchor /, @Template::Caribou::Tags::HTML::TAGS
    ],
};

sub css($) {
    my $css = shift;
    render_tag( 'style', sub {
        attr type => 'text/css';
        $css;
    });
};

sub anchor($$) {
    my ( $href, $inner ) = @_;
    render_tag( a => sub {
        attr href => $href;
        ref $inner ? $inner->() : $inner;
    });
}

1;
