use strict;
use warnings;

use autodie;

use Test::More tests => 1;

-d $_ or mkdir $_ for map "t/$_", qw/ foo bar /;

{ 
    package Bar;

    use Moose::Role;
    use Template::Caribou;

    with 'Template::Caribou::Files' => {
        dirs => [ 't/bar' ],
    };
}

{ 
    package Foo;

    use Moose;
    use Template::Caribou;
    with 'Template::Caribou::Files' => {
        dirs => [ 't/foo' ],
    };
    with 'Bar';
}

my $foo = Foo->new;

is_deeply [ $foo->all_template_dirs ], [ map "t/$_", qw/ foo bar / ], 'all_template_dirs';



