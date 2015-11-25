use strict;
use warnings;

use 5.10.0;

use Test::More;

use Template::Caribou;
use Template::Caribou::Tags qw/ render_tag /;

my $self = __PACKAGE__->new;

template inner_tmpl => sub {
    'hello world';
};

template outer => sub {
    print 'x';
    show( 'inner_tmpl' );
    print 'x';
};

subtest 'inner_tmpl' => sub {
    my $self = shift;

    is $self->render('inner_tmpl') => 'hello world';
};

subtest 'outer' => sub {
    is $self->render('outer') => 'xhello worldx';
};

sub foo(&) { render_tag( 'foo', shift ) }
sub bar(&) { render_tag( 'bar', shift ) }

template 'escape_outer' => sub {
    foo {};
    foo { show( 'escape_inner' ); };
    foo {};
};

template 'escape_inner' => sub {
    bar { '<yay>' };
};

subtest 'escaping' => sub {
    is $self->render('escape_outer') 
        => qq{<foo /><foo><bar>&lt;yay></bar></foo><foo />};
};

template 'end_show' => sub {
    foo { };
    show( 'inner_tmpl' );
};

subtest 'end_show' => sub {
    is $self->render( 'end_show' ) => '<foo />hello world';
};

template 'attributes' => sub {
    foo {
        attr foo => 'bar';
        attr 'foo';
    };
    foo {
        attr a => 1, b => 2;
        attr '+a' => 3, b => 4;
    }
};

subtest attributes => sub {
    is $self->render( 'attributes' ) => 
        '<foo foo="bar">bar</foo><foo a="1 3" b="4" />';
};

subtest "print vs say" => sub {
    TODO: {
        local $TODO = "Perl bug, should be fixed in 5.18";

        is $self->render(sub{
            print "one";
            say "two";
            print ::RAW "three";
            say ::RAW "four";
        }) => "onetwo\nthreefour\n";
    }
};

done_testing;
