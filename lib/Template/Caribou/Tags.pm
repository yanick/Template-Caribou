package Template::Caribou::Tags;
#ABSTRACT: generates tags functions for Caribou templates

use strict;
use warnings;

use Carp;

use experimental 'signatures';

use Template::Caribou::Utils ();

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

sub render_tag {
    my ( $tag, $inner_sub, $groom ) = @_;

    my $inner;
    my %attr;

    {
        no warnings qw/ uninitialized /;

        local *STDOUT;
        local *::RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::Attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';

        my $res = ref $inner_sub ? $inner_sub->() : $inner_sub;

        $inner = $Template::Caribou::OUTPUT 
            || ( ref $res ? $res : Template::Caribou::Output::escape( $res ) );

        %attr = %Template::Caribou::Attr;
    }

    if ( $groom ) {
        $groom->( \%attr, \$inner );
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
