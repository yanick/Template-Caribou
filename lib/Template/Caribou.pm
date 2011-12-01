package Template::Caribou;

use strict;
use warnings;

use Moose::Role;

sub add_template {
    my ( $self, $label, $sub ) = @_;

    my $wrapper = sub {
        # $self is the Caribou object

        my $output;
        {
            local *STDOUT;
            open STDOUT, '>', \$output;
            $sub->( $self, @_ );
        }

        print $output unless defined wantarray;

        return $output;
    };

    $self->meta->add_method( "template_$label" => $wrapper );

}

sub render {
    my ( $self, $template, @args ) = @_;

    $self->templates->$template( @args );
}

1;



