package UseCase::One;

use strict;
use warnings;

use Moose;

use Template::Caribou::Utils;
use Template::Caribou::Tags::HTML qw/ :all /;

with 'Template::Caribou';

__PACKAGE__->import_template( 't/corpus/usecase_1.bou' );

1;
