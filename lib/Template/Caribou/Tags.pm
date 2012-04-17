package Template::Caribou::Tags;
#ABSTRACT: generates tags functions for Caribou templates

use strict;
use warnings;

use Template::Caribou::Utils;

use Sub::Exporter -setup => {
    exports => [
        mytag => \&_gen_generic_tag,
        map { $_ => \&_gen_simple_tag } qw/ 
            p html head h1 body emphasis div
            style title span
        /,
    ],
};

sub _gen_generic_tag {
    my ( undef, $name, $arg ) = @_;

    my $c = $arg->{class};

    return sub(&) {
        my $inner = shift;
        render_tag( $arg->{tag} || 'div', 
            sub {
            attr class => $c if defined $c;
            $inner->();
            }
           )
    }
}

1;
