package Template::Caribou::Template;

use strict;
use warnings;

use Moose;

use Moose::Exporter;

Moose::Exporter->setup_import_methods( with_meta => [ 'template'], );

sub template { 
    my ( $meta, $label, $sub ) = @_;

    $meta->add_method( "template_$label" => $sub );
}


__PACKAGE__->meta->make_immutable;

1;



