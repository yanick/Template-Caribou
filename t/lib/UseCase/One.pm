package UseCase::One;

use strict;
use warnings;

use Moose;

use Template::Caribou::Utils qw/ attr /;
use Template::Caribou::Tags::HTML qw/ :all /;

use Template::Caribou;

with 'Template::Caribou::Files' => {
    dirs => [ 't/corpus' ],
};

1;
