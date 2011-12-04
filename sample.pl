#!/usr/bin/perl 

use strict;
use warnings;

use Sample;

my $s = Sample->new;

print $s->render( 'hello' );

print $s->render( 'two levels' );

sub p(&) {
    my $inner = do {
        local *STDOUT;
        local *RAW;
        local $Template::Caribou::OUTPUT;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *RAW, 'Template::Caribou::OutputRaw';
        my $res = $_[0]->();

        $Template::Caribou::OUTPUT 
            || ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    my $output = Template::Caribou::String->new( "<p>$inner</p>" );
    print $output unless defined wantarray;
    return $output;
}

sub make_tag {
    my $tag = shift;

    eval "sub $tag(&) { die 'yay' } ";
    die $@ if $@;

}

make_tag( 'foo' );

foo { 'ggg' };





p { p { "stuff" } };

package Template::Caribou::String;

use overload 
    '""' => sub { return ${$_[0] } };

sub new { my ( $class, $string ) = @_;  bless \$string, $class; }


package Template::Caribou::Output;
use Tie::Handle;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub PRINT { print RAW escape( @_ ) } 

sub escape {
    @_ = map { 
        my $x = $_;
        $x =~ s/&/&amp;/g;
        $x =~ s/</<&lt;/;
        $x;
    } @_;

    return wantarray ? @_ : join '', @_;
}

package Template::Caribou::OutputRaw;
use Tie::Handle;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub PRINT { $Template::Caribou::OUTPUT .= $_ for @_ } 



