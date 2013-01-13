use strict;
use warnings;

use lib 't/lib';

use UseCase::Two;

use Test::More;

my $bou = UseCase::Two->new( 
    formatter => '+Twig',
);

is_deeply [ sort $bou->all_templates ] => [ qw/ body head page / ], "template names"
    or diag explain [ sort $bou->all_templates ];

note $bou->render('page');

done_testing;
