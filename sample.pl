#!/usr/bin/perl 

use strict;
use warnings;

use Sample;

my $s = Sample->new;

print $s->render( 'hello' );

print $s->render( 'two levels' );



