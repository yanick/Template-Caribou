use strict;
use warnings;

use Test::More;

use Test::Routine;
use Test::Routine::Util;

use Template::Caribou::Utils;

use Method::Signatures;

with 'Template::Caribou';

use Template::Caribou::Tags 
    mytag => { name => 'foo', -as => 'foo' },
    mytag => { name => 'bar', -as => 'bar' },
;

test string => method {
    is $self->render(sub { 'hi there' }) => 'hi there';
};

test one_tag => method {
    is $self->render(sub { foo { } }) => '<foo />';
    is $self->render(sub { foo { 'moin' } }) => '<foo>moin</foo>';
};

test two_tags => method {
    is $self->render(sub { foo { bar { 'yay' } } }) => "<foo><bar>yay</bar></foo>";
};

run_me;
done_testing;
