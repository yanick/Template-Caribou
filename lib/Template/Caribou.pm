package Template::Caribou;

use strict;
use warnings;

use Moose::Role;
use Template::Caribou::Template;

sub add_template {
    my ( $self, $label, $sub ) = @_;

    template( $self->meta, $label, $sub );
}

sub render {
    my ( $self, $template, @args ) = @_;

    my $method = "template_$template";

    my $output;
    {
        local *STDOUT;
        open STDOUT, '>', \$output;
        $self->$method( @_ );
    }

    print $output unless defined wantarray;

    return $output;
}

1;



