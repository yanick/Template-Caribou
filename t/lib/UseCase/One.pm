package UseCase::One;

use strict;
use warnings;

use Template::Caribou;

with 'Template::Caribou::Files' => {
    dirs => [ 't/corpus' ],
};

1;
