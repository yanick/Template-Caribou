package UseCase::Two;

use strict;
use warnings;

use Moose;

use Template::Caribou::Utils;
use Template::Caribou::Tags qw/ attr /;
use Template::Caribou::Tags::HTML qw/ :all /;

with 'Template::Caribou';

__PACKAGE__->import_template_dir( 't/corpus/usecase_2' );

1;


