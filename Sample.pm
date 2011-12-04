package Sample;

use strict;
use warnings;

use Moose;
use Template::Caribou::Template;

with 'Template::Caribou';

sub p(&) {
    my $inner;
    my $output; 
    {
        local *STDOUT;
        open STDOUT, '>', \$output;
        my $res = $_[0]->();
        $output ||= $res;
    }
    $output = "<p>$output</p>";
    print $output unless defined wantarray;
    return $output;
}

template 'hello' => sub {
    p { p { "hello world" } };
};

template 'two levels' => sub {
    print "two levels";
    $_[0]->render( 'hello' );
};

__PACKAGE__->meta->make_immutable;

1;



