package Template::Caribou::Utils;

use strict;
use warnings;
no warnings qw/ uninitialized /;

BEGIN {
    *::RAW = *::STDOUT;
}

use parent 'Exporter::Tiny';

use Carp;

use Template::Caribou::Tags qw/ attr /;

our @EXPORT = qw/ template show /;

sub template {
    my $class = eval { $_[0]->DOES('Template::Caribou') } ? shift : caller;
    $class->set_template( @_ );
}

=function show( $template, @args )

Must be called from inside a template. Prints out
the result of the rendering in addition of returning it.

    template foo => sub {

        print "yadah";

        show( 'bar' );

        print "yadah";
    };

=cut

sub show {
    croak "'show()' must be called from within a template"
        unless $Template::Caribou::IN_RENDER;

    print ::RAW $Template::Caribou::TEMPLATE->render( @_ );
}

package
    Template::Caribou::String;

use overload 
    '""' => sub { return ${$_[0] } },
    'eq' => sub { ${$_[0]} eq $_[1] };

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



