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

use Template::Caribou::Utils qw/ attr /;
use Template::Caribou::Tags qw/ render_tag /;

sub _row_tag {
    my( undef, undef, $arg ) = @_;


    my $groom = sub {
        $_{class} .= ' row';
        $_{class} .= '-fluid' if $_{fluid};
    };

    return sub(&) {
        render_tag( 'div', shift, $groom );
    }
}

sub _span_tag {
    my( undef, undef, $arg ) = @_;

    my $groom = sub {
        $_{class} .= ' span' . $_{span} || 1;
        $_{class} .= ' offset' . $_{offset} if $_{offset};
    };

    return sub(&) {
        render_tag( 'div', shift, $groom );
    }
}



1;
