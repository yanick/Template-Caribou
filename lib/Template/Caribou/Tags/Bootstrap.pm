package Template::Caribou::Tags::Bootstrap;
BEGIN {
  $Template::Caribou::Tags::Bootstrap::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Tags::Bootstrap::VERSION = '0.2.0';
}

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [
        row => \&_row_tag,
        span => \&_span_tag,
    ],
    groups => { default => ':all' },
};

use Template::Caribou::Tags
    'render_tag',
    'attr';

sub _row_tag {
    my( undef, undef, $arg ) = @_;


    my $groom = sub {
        my( $attr ) = @_;
        $attr->{class} .= ' row';
        $attr->{class} .= '-fluid' if $arg->{fluid};
    };

    return sub(&) {
        render_tag( 'div', shift, $groom );
    }
}

sub _span_tag {
    my( undef, undef, $arg ) = @_;

    my $groom = sub {
        my( $attr ) = @_;
        $attr->{class} .= ' span' . $arg->{span} || 1;
        $attr->{class} .= ' offset' . $arg->{offset} if $arg->{offset};
    };

    return sub(&) {
        render_tag( 'div', shift, $groom );
    }
}



1;

__END__

=pod

=head1 NAME

Template::Caribou::Tags::Bootstrap

=head1 VERSION

version 0.2.0

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
