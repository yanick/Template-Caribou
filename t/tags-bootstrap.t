use strict;
use warnings;

package Test;

use Test::More tests => 1;

use Template::Caribou::Tags::Bootstrap
    row => { -as => 'main' };

use Moose;

with 'Template::Caribou';

my $bou = Test->new;

sub render_ok(&$$) {
    my ( $template, $expected, $title) = @_;
    is $bou->render($template), $expected, $title;
}

render_ok sub { main { }; } 
    => '<div class=" row" />', 'row';

