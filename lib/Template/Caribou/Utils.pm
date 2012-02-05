package Template::Caribou::Utils;
BEGIN {
  $Template::Caribou::Utils::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Utils::VERSION = '0.1.0';
}

use strict;
use warnings;
no warnings qw/ uninitialized /;

use Moose;

use Moose::Exporter;

BEGIN {
    *::RAW = *::STDOUT;
}

Moose::Exporter->setup_import_methods( 
    with_meta => [ 'template'], 
    as_is => [ 'render_tag', 'attr', 'show' ] 
);

sub attr(@){
    my %attr = @_;
    $Template::Caribou::attr{$_} = $attr{$_} for keys %attr;
    return;
}

sub template { 
    my ( $meta, $label, $sub ) = @_;

    $meta->add_method( "template_$label" => $sub );
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

        local $Template::Caribou::INDENT = $Template::Caribou::INDENT + 1;

        my $res = $inner_sub->();

        $inner = $Template::Caribou::OUTPUT 
            || ( ref $res ? $res : Template::Caribou::Output::escape( $res ) );

        %attr = %Template::Caribou::attr;
    }

    $groom->( \%attr, \$inner ) if $groom;

    my $attrs;
    while( my ( $tag, $value ) = each %attr ) {
        # TODO deal with the quotes
        $attrs .= qq{ $tag="$value"};
    }

    my $indent;

    if ( $Template::Caribou::INDENT ) {
        $indent = "\n" . ( ' ' x $Template::Caribou::INDENT );
    }

    no warnings qw/ uninitialized /;
    my $output = Template::Caribou::String->new( 
        "<${tag}$attrs$indent>$inner</$tag>" 
    );
    print ::RAW $output;
    return $output;
}

sub show {
    print ::RAW $Template::Caribou::TEMPLATE->render( @_ );
}


__PACKAGE__->meta->make_immutable;

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




__END__
=pod

=head1 NAME

Template::Caribou::Utils

=head1 VERSION

version 0.1.0

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

