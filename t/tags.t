use strict;
use warnings;

use Test::More tests => 7;

use Template::Caribou::Tags qw/ render_tag /;

local *::RAW;
open ::RAW, '>', \my $raw;

is render_tag(
    'div', sub { "hello there" }
) => '<div>hello there</div>';

is render_tag(
    'div', sub { "hello there" }, sub { } 
) => '<div>hello there</div>';

is render_tag( 'div', 'X', sub { s/X/Y/ } ), '<div>Y</div>', 'grooming $_';
is render_tag( 'div', 'X', sub { $_{bar} = 'baz' } ), '<div bar="baz">X</div>', 'grooming %_';

use Template::Caribou::Tags
    mytag => { -as => 'foo' },
    mytag => { -as => 'bar', tag => 'bar' },
    mytag => { 
        -as => 'baz', 
        tag => 'zab',
        groom => sub { s//yay/ },
        class => 'quux',
        attr => { style => '!' },
    };

is( Template::Caribou::Role->render(sub{ foo {}  }) => '<div />' );
is( Template::Caribou::Role->render(sub{ bar {}  }) => '<bar />' );
is( Template::Caribou::Role->render(sub{ baz {}  }) => '<zab class="quux" style="!">yay</zab>' );
