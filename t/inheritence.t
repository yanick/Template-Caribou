use strict;
use warnings;

use Test::More tests => 1;
use Moose::Util qw/ with_traits /;

{ 
    package Bar;

    use Moose::Role;
    use Template::Caribou;

    with 'Template::Caribou';

    template bar => sub { 'bar' };

}
{ 
    
    package Foo;

    use Moose;
    use Template::Caribou;

    with 'Template::Caribou';

    template foo => sub { print 'x'; show('bar') };

}

my $class = with_traits( 'Foo', 'Bar' );

is( $class->new->render('foo') => 'xbar', 'template inherited' );



