package Template::Caribou::Utils;

use strict;
use warnings;
no warnings qw/ uninitialized /;

BEGIN {
    *::RAW = *::STDOUT;
}


use parent 'Exporter::Tiny';

use Template::Caribou::Tags qw/ attr /;

our @EXPORT = qw/ template attr /;

sub template {
    my $class = eval { $_[0]->DOES('Template::Caribou') } ? shift : caller;
    $class->set_template( @_ );
}

package
    Template::Caribou::String;

use overload 
    '""' => sub { return ${$_[0] } };

sub new { my ( $class, $string ) = @_;  bless \$string, $class; }


package 
    Template::Caribou::Output;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub escape {
    no warnings qw/ uninitialized/;
    @_ = map { 
        my $x = $_;
        $x =~ s/&/&amp;/g;
        $x =~ s/</&lt;/g;
        $x;
    } @_;

    return wantarray ? @_ : join '', @_;
}

sub PRINT { shift; print ::RAW escape( @_ ) } 

package
    Template::Caribou::OutputRaw;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub PRINT { 
    shift;
    no warnings qw/ uninitialized /;
    $Template::Caribou::OUTPUT .= join '', @_, $\;
} 

1;



