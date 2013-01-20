package Template::Caribou::Tags::Bootstrap;

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [
        row => \&_row_tag,
        span => \&_span_tag,
    ],
    groups => { default => ':all' },
};

use Template::Caribou::Tags
    'render_tag',
    'attr';

sub _row_tag {
    my( undef, undef, $arg ) = @_;


    my $groom = sub {
        my( $attr, $inner ) = @_;
        $attr->{class} .= ' row';
        $attr->{class} .= '-fluid' if $arg->{fluid};
    };

    return sub(&) {
        my $inner = shift;
        render_tag( 'div', $inner, $groom );
    }
}

sub _span_tag {
    my( undef, undef, $arg ) = @_;

    my $groom = sub {
        my( $attr, $inner ) = @_;
        $attr->{class} .= ' span' . $arg->{span} || 1;
        $attr->{class} .= ' offset' . $arg->{offset} if $arg->{offset};
    };

    return sub(&) {
        my $inner = shift;
        render_tag( 'div', $inner, $groom );
    }
}



1;
