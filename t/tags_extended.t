use strict;
use warnings;

package Test;

use Test::More tests => 5;

use Template::Caribou::Tags::HTML::Extended ':all';

use Moose;

with 'Template::Caribou';

my $bou = Test->new;

sub r(&) {
    $bou->render(shift);
}


is r { css "X" } 
    => '<style type="text/css">X</style>', 'css';

is r { anchor "http://foo.com" => 'linkie' }
    => '<a href="http://foo.com">linkie</a>', 'anchor';

is r { anchor "http://foo.com" => sub {
    print ::RAW "this <b>thing</b>";
} } => '<a href="http://foo.com">this <b>thing</b></a>', 'anchor';

is r { image "/foo.jpg" } => '<img src="/foo.jpg" />', 'image';

is r { markdown "this is *awesome*" } => "<p>this is <em>awesome</em></p>\n", 'markdown';

