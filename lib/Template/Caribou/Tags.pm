package Template::Caribou::Tags;
#ABSTRACT: generates tags functions for Caribou templates


use strict;
use warnings;

use Carp;

use Template::Caribou::Role;

use parent 'Exporter::Tiny';
use experimental 'signatures';


our @EXPORT_OK = qw/ render_tag mytag attr /;


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


sub _generate_mytag {
    my ( undef, undef, $arg ) = @_;

    $arg->{'-as'} ||= $arg->{tag}
        or die "mytag needs to be given '-as' or 'name'\n";

    my $tagname = $arg->{tag} || 'div';

    my $groom = sub {
        $_{class} ||= $arg->{class} if $arg->{class};

        $_{$_} ||= $arg->{attr}{$_} for eval { keys %{ $arg->{attr} } };

        $arg->{groom}->() if $arg->{groom};
    };

    return sub :prototype(&) {
        my $inner = shift;
        render_tag( $tagname, $inner, $groom, $arg->{indent}//1 );
    }
}


sub render_tag {
    my ( $tag, $inner_sub, $groom, $indent ) = @_;

    $indent //= 1;

    local $Template::Caribou::TAG_INDENT_LEVEL = $indent ? $Template::Caribou::TAG_INDENT_LEVEL : 0;

    my $sub = ref $inner_sub eq 'CODE' ? $inner_sub : sub { $inner_sub };

    # need to use the object for calls to 'show'
    my $bou = $Template::Caribou::TEMPLATE || Moose::Meta::Class->create_anon_class(
        roles => [ 'Template::Caribou::Role' ] 
    )->new_object;

    local %Template::Caribou::Attr;

    my $inner = do {
        local $Template::Caribou::TAG_INDENT_LEVEL = $Template::Caribou::TAG_INDENT_LEVEL;

        $Template::Caribou::TAG_INDENT_LEVEL++
            if $Template::Caribou::TAG_INDENT_LEVEL // $bou->indent;

        $bou->get_render($sub);
    };

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

    my $prefix = !!$Template::Caribou::TAG_INDENT_LEVEL 
        && "\n" . ( '  ' x $Template::Caribou::TAG_INDENT_LEVEL );

    my $output = length($inner) 
        ? Template::Caribou::String->new( "$prefix<${tag}$attrs>$inner$prefix</$tag>" ) 
        : Template::Caribou::String->new( "$prefix<${tag}$attrs />" ) 
        ;

    return print_raw( $output );
}

sub print_raw($text) {
    print ::RAW $text;
    return $text; 
}

1;
