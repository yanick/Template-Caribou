package Template::Caribou::Utils;

use strict;
use warnings;
no warnings qw/ uninitialized /;

BEGIN {
    *::RAW = *::STDOUT;
}

use parent 'Exporter::Tiny';

use experimental 'signatures';

use Carp;

our @EXPORT = qw/ template show attr  /;

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

=function attr( $name => $value )

Accesses the attributes of a tag within its block.

If provided an even number of parameters, sets the attributes to those values.


    div {
        attr class => 'foo', 
             style => 'text-align: center';

        "hi there";
    };

    # <div class="foo" style="text-align: center">hi there</div>
    
Many calls to C<attr> can be done within the same block.

    div {
        attr class => 'foo';
        attr style => 'text-align: center';

        "hi there";
    };

    # <div class="foo" style="text-align: center">hi there</div>
  
To add to an attribute instead of replacing its value, prefix the attribute name
with a plus sign.

    div {
        attr class    => 'foo';

        attr '+class' => 'bar';

        "hi there";
    };

    # <div class="foo bar">hi there</div>
   
The value of an attribute can also be queried by passing a single argument to C<attr>.

    div { 
        ...; # some complex stuff here

        my $class = attr 'class';

        attr '+style' => 'text-align: center' if $class =~ /_centered/;

        ...;
    }
    

=cut

sub attr(@attrs){
    return $Template::Caribou::Attr{$_[0]} if @_ == 1;

    croak "number of attributes must be even" if @_ % 2;

    while( my ( $k, $v ) = splice @_, 0, 2 ) {
        if ( $k =~ s/^\+// ) {
            $Template::Caribou::Attr{$k} .= ' '. $v;
        }
        else {
            $Template::Caribou::Attr{$k} = $v;
        }
    }

    return;
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



