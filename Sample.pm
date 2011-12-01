package Sample;

use strict;
use warnings;

use Moose;

with 'Template::Caribou';

__PACKAGE__->add_template( 'hello' => sub {
    print "hello world";
} );

__PACKAGE__->add_template( 'two levels' => sub {
    print "two levels";
    $_[0]->render( 'hello' );
} );

__PACKAGE__->meta->make_immutable;

1;



