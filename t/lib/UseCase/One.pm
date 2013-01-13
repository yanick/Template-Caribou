package UseCase::One;

use strict;
use warnings;

use Moose;

use Template::Caribou::Utils;
use Template::Caribou::Tags qw/ attr /;
use Template::Caribou::Tags::HTML qw/ :all /;

with 'Template::Caribou';

with 'Template::Caribou::Files' => {
    dirs => [ 't/corpus' ],
};

1;
