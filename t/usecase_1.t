use strict;
use warnings;

use lib 't/lib';

use UseCase::One;

use Test::More;

my $bou = UseCase::One->new( pretty_render => 1 );

is ref( $bou->t( "usecase_1" ) ) => 'CODE', 'template loaded';

my $output = $bou->render( 'usecase_1' );

note $output;

like $output => qr#^<html>\n\s{2}<head>#, "nicely formatted";

done_testing;
