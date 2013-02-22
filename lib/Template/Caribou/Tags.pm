package Template::Caribou::Tags;
BEGIN {
  $Template::Caribou::Tags::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Tags::VERSION = '0.2.0';
}
#ABSTRACT: generates tags functions for Caribou templates

use strict;
use warnings;

use Carp;

use Template::Caribou::Utils;

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
    return $Template::Caribou::attr{$_[0]} if @_ == 1;

    croak "number of attributes must be even" if @_ % 2;

    while( my ( $k, $v ) = splice @_, 0, 2 ) {
        if ( $k =~ s/^\+// ) {
            $Template::Caribou::attr{$k} .= ' '. $v;
        }
        else {
            $Template::Caribou::attr{$k} = $v;
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
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';

        $DB::single = 1;

        my $res = ref $inner_sub ? $inner_sub->() : $inner_sub;

        $inner = $Template::Caribou::OUTPUT 
            || ( ref $res ? $res : Template::Caribou::Output::escape( $res ) );

        %attr = %Template::Caribou::attr;
    }

    $groom->( \%attr, \$inner ) if $groom;

    my $attrs;
    for( sort keys %attr ) {
        # TODO deal with the quotes
        $attrs .= qq{ $_="$attr{$_}"};
    }

    $DB::single = 1;
    no warnings qw/ uninitialized /;
    my $output = $inner 
        ? Template::Caribou::String->new( "<${tag}$attrs>$inner</$tag>" ) 
        : Template::Caribou::String->new( "<${tag}$attrs />" ) 
        ;
    print ::RAW $output;
    return $output;
}

1;

__END__

=pod

=head1 NAME

Template::Caribou::Tags - generates tags functions for Caribou templates

=head1 VERSION

version 0.2.0

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
