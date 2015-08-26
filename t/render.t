use strict;
use warnings;

use Test::More;

use Test::Routine;
use Test::Routine::Util;

use Template::Caribou::Utils;

with 'Template::Caribou';

use Template::Caribou::Tags 
    mytag => { name => 'foo', -as => 'foo' },
    mytag => { name => 'bar', -as => 'bar' },
;

test string => sub {
    my $self = shift;
    
    is $self->render(sub { 'hi there' }) => 'hi there';
};

test one_tag => sub {
    my $self = shift;
    is $self->render(sub { foo { } }) => '<foo />';
    is $self->render(sub { foo { 'moin' } }) => '<foo>moin</foo>';
};

test two_tags => sub {
    my $self = shift;
    is $self->render(sub { foo { bar { 'yay' } } }) => "<foo><bar>yay</bar></foo>";
};

run_me;
done_testing;
