use strict;
use warnings;

use Test::More tests => 4;

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

