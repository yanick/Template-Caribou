use strict;
use warnings;

use Test::More;

use Test::Routine;
use Test::Routine::Util;

use Template::Caribou::Utils;

with 'Template::Caribou';

test 'it works' => sub {
    pass;
};

template inner => sub {
    'hello world';
};

template outer => sub {
    print 'x';
    show( 'inner' );
    print 'x';
};

test 'inner' => sub {
    my $self = shift;

    is $self->render('inner') => 'hello world';
};

test 'outer' => sub {
    my $self = shift;

    is $self->render('outer') => 'xhello worldx';
};

sub foo(&) { render_tag( 'foo', shift ) }
sub bar(&) { render_tag( 'bar', shift ) }

template 'escape_outer' => sub {
    foo {};
    foo {
        show( 'escape_inner' );
    };
    foo {};
};

template 'escape_inner' => sub {
    bar { '<yay>' };
};

test 'escaping' => sub {
    my $self = shift;

    is $self->render('escape_outer') 
        => qq{<foo></foo><foo><bar\n >&lt;yay></bar></foo><foo></foo>};

};

template 'end_show' => sub {
    foo { };
    show( 'inner' );
};

test 'end_show' => sub {
    my $self = shift;

    is $self->render( 'end_show' ) => '<foo></foo>hello world';
};

run_me;
done_testing;




