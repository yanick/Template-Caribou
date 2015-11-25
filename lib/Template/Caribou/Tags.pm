package Template::Caribou::Tags;
#ABSTRACT: generates tags functions for Caribou templates

use strict;
use warnings;

use Carp;

use experimental 'signatures';

use Template::Caribou::Utils ();
use Template::Caribou::Role;

use Sub::Exporter -setup => {
    exports => [
        qw/ attr render_tag /,
        mytag => \&_gen_generic_tag,
    ],
    groups => { default => [ 'attr' ] },
};

sub _gen_generic_tag {
    my ( undef, undef, $arg ) = @_;

    my $groom = $arg->{groom} || sub {
        my( $attr ) = @_;
        $attr->{class} ||= $arg->{class} if $arg->{class};
        if ( $arg->{attr} ) {
            $attr->{$_} ||= $arg->{attr}{$_} for keys %{ $arg->{attr} };
        }
    };

    return sub(&) {
        my $inner = shift;
        render_tag( $arg->{name} || 'div', $inner, $groom );
    }
}

sub attr(@){
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

=function render_tag( $tag_name, $inner_block, \&groom )

Prints out a tag in a template. The C<$inner_block> is a string or coderef
holding the content of the tag. 

If the C<$inner_block> is empty, the tag will be of the form
C<< <foo /> >>.

    render_tag( 'div', 'hello' );         #  <div>hello</div>

    render_tag( 'div', sub { 'hello' } )  # <div>hello</div>

    render_tag( 'div', '' );              #  <div />

An optional grooming function can be passed. If it is, an hash holding the 
attributes of the tag, and its inner content will be passed to it as C<%_> and C<$_>, respectively.

   # '<div>the current time is Wed Nov 25 13:18:33 2015</div>'
   render_tag( 'div', 'the current time is DATETIME', sub {
        s/DATETIME/scalar localtime/eg;
   });

   # '<div class="mine">foo</div>'
   render_tag( 'div', 'foo', sub { $_{class} = 'mine' } )




=cut

sub render_tag {
    my ( $tag, $inner_sub, $groom ) = @_;

    my $sub = ref $inner_sub eq 'CODE' ? $inner_sub : sub { $inner_sub };

    # need to use the object for calls to 'show'
    my $bou = $Template::Caribou::TEMPLATE || 'Template::Caribou::Role';

    local %Template::Caribou::Attr;

    my $inner = $bou->render($sub);

    my %attr = %Template::Caribou::Attr;

    if ( $groom ) {
        local $_ = "$inner";  # stringification required in case it's an object
        local %_ = %attr;

        $groom->();

        ($inner,%attr) = ( $_, %_ );
    }

    my $attrs;
    for( sort keys %attr ) {
        # TODO deal with the quotes
        $attrs .= qq{ $_="$attr{$_}"};
    }

    no warnings qw/ uninitialized /;
    my $output = $inner 
        ? Template::Caribou::String->new( "<${tag}$attrs>$inner</$tag>" ) 
        : Template::Caribou::String->new( "<${tag}$attrs />" ) 
        ;
    print ::RAW $output;
    return $output;
}

1;
