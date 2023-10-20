package Template::Caribou::Tags;
#ABSTRACT: generates tags functions for Caribou templates

use strict;
use warnings;

use Carp;

use Template::Caribou::Role;

use List::AllUtils qw/ pairmap pairgrep /;
use Ref::Util qw/ is_plain_hashref /;

use parent 'Exporter::Tiny';
use experimental 'signatures', 'postderef';
use XML::Writer;

our @EXPORT_OK = qw/ render_tag mytag attr /;


sub attr(@args){
    return $_{$args[0]} if @args == 1;

    croak "number of attributes must be even" if @args % 2;

    no warnings 'uninitialized';
    while( my ( $k, $v ) = splice @args, 0, 2 ) {
        if ( $k =~ s/^\+// ) {
            $_{$k} = { map { $_ => 1 } split ' ', $_{$k} }
                unless ref $_{$k};

            $_{$k}{$v} = 1;
        }
        elsif ( $k =~ s/^-// ) {
            $_{$k} = { map { $_ => 1 } split ' ', $_{$k} }
                unless ref $_{$k};

            delete $_{$k}{$v};
        }
        else {
            $_{$k} = $v;
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
        
        no warnings 'uninitialized';

        if( my $defaults = $arg->{classes} || $arg->{class} ) {
            $_{class} = { map { $_ => 1 } split ' ', $_{class} }
                unless ref $_{class};
            if( ref $defaults ) {
                $_{class}{$_} //= 1 for @$defaults;
            }
            else {
                $_{class}{$_} //=  1 for split ' ', $defaults;
            }
        }

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

    local %_;

    my $inner = do {
        local $Template::Caribou::TAG_INDENT_LEVEL = $Template::Caribou::TAG_INDENT_LEVEL;

        $Template::Caribou::TAG_INDENT_LEVEL++
            if $Template::Caribou::TAG_INDENT_LEVEL // $bou->indent;

        $bou->get_render($sub);
    };

    if ( $groom ) {
        local $_ = "$inner";  # stringification required in case it's an object

        $groom->();

        $inner = $_;
    }

    # Setting UNSAFE here so that the inner can be written with raw
    # as we don't want inner to be escaped as it is already escaped
    my $writer = XML::Writer->new(OUTPUT => 'self', UNSAFE => 1);
    my @attributes = pairmap { (  $a => $b ) x (length $b > 0) }
        map { 
            $_ => is_plain_hashref($_{$_})
                ? join ' ', sort { $a cmp $b } pairmap { $a } pairgrep { $b } $_{$_}->%* 
                : $_{$_} 
        }
       grep { defined $_{$_} }
       sort keys %_;

    no warnings qw/ uninitialized /;

    my $prefix = !!$Template::Caribou::TAG_INDENT_LEVEL
        && "\n" . ( '  ' x $Template::Caribou::TAG_INDENT_LEVEL );

    if (length($inner)) {
        $writer->startTag($tag, @attributes);
        $writer->raw("$inner$prefix");
        $writer->endTag($tag);
    }
    else {
        $writer->emptyTag($tag, @attributes);
    }

    my $output = Template::Caribou::String->new( $prefix . $writer->to_string() );

    return print_raw( $output );
}

sub print_raw($text) {
    print ::RAW $text;
    return $text;
}

1;
