use strict;
use warnings;

use lib 't/lib';

use UseCase::One;
use Template::Caribou::Formatter::Twig;

use Test::More;

my $bou = UseCase::One->new( 
    formatter => Template::Caribou::Formatter::Twig->new,
);

is ref( $bou->t( "usecase_1" ) ) => 'CODE', 'template loaded';

my $output = $bou->render( 'usecase_1' );

note $output;

like $output => qr#^<html>\n\s{2}<head>#, "nicely formatted";

$bou->set_formatter('Template::Caribou::Formatter::Twig');

like $output => qr#^<html>\n\s{2}<head>#, "nicely formatted";

$bou->set_formatter('+Twig');

like $output => qr#^<html>\n\s{2}<head>#, "nicely formatted";

done_testing;
