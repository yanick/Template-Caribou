use strict;
use warnings;

use Test::More tests => 1;

{ 
    package Bar;

    use Moose::Role;
    use Template::Caribou;

    with 'Template::Caribou::Files' => {
        dirs => [ 'bar' ],
    };
}

{ 
    package Foo;

    use Moose;
    use Template::Caribou;
    with 'Template::Caribou::Files' => {
        dirs => [ 'foo' ],
    };
    with 'Bar';
}

my $foo = Foo->new;

is_deeply [ $foo->all_template_dirs ], [ qw/ foo bar / ], 'all_template_dirs';



