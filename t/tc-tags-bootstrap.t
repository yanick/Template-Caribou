package TestsFor::Template::Caribou::Tags::Bootstrap;

use strict;
use warnings;

use 5.20.0;

use Test::More tests => 1;

use Moose;

use experimental 'signatures';

use Template::Caribou::Tags::Bootstrap
   row => { -as => 'main' };

with 'Template::Caribou';

sub render_ok( $template, $expected, $title ) {
    state $self = __PACKAGE__->new;
    is $self->render($template), $expected, $title;
}

subtest row_as_main => sub {
    render_ok sub { main { }; }, '<div class=" row" />', 'main is alias for row';
}

