package Template::Caribou::Tags::HTML::Extended;

use strict;
use warnings;

use Template::Caribou::Utils;

BEGIN {
    @Template::Caribou::Tags::HTML::Extended::TAGS =  qw/
        css anchor
    /;
}

use Sub::Exporter -setup => {
    exports => [
        @Template::Caribou::Tags::HTML::Extended::TAGS
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
