use strict;
use warnings;

use Test::More tests => 1;
use Moose::Util qw/ with_traits /;

{ 
    package Bar;

    use Moose::Role;
    with 'Template::Caribou::Role';
    use Template::Caribou::Utils 'template';

    template bar => sub { 'bar' };
}
{ 
    
    package Foo;

    use Template::Caribou;

    with 'Bar';

    template foo => sub { print 'x'; show('bar') };

}

is( Foo->new->render('foo') => 'xbar', 'template inherited' );



