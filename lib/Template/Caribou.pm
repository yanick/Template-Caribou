package Template::Caribou;
BEGIN {
  $Template::Caribou::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::VERSION = '0.1.0';
}
# ABSTRACT: class-based *ML-centric templating system


use strict;
use warnings;
no warnings qw/ uninitialized /;

use Moose::Role;
use Template::Caribou::Utils;

sub add_template {
    my ( $self, $label, $sub ) = @_;

    template( $self->meta, $label, $sub );
}

sub render {
    my ( $self, $template, @args ) = @_;

    my $method = "template_$template";

    my $output = do
    {
        local $Template::Caribou::TEMPLATE =
            $Template::Caribou::TEMPLATE || $self;
            
        local $Template::Caribou::IN_RENDER = 1;
        local *STDOUT;
        local *::RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';
        my $res = $self->$method( @_ );

        $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    # if we are still within a render, we turn the string
    # into an object to say "don't touch"
    $output = Template::Caribou::String->new( $output ) 
        if $Template::Caribou::IN_RENDER;

    print ::RAW $output if $Template::Caribou::IN_RENDER and not defined wantarray;

    return $output;
}

1;




__END__
=pod

=head1 NAME

Template::Caribou - class-based *ML-centric templating system

=head1 VERSION

version 0.1.0

=head1 SYNOPSIS

    package MyTemplate;

    use Moose;
    with 'Template::Caribou';

    use Template::Caribou::Utils;
    use Template::Caribou::Tags::HTML;

    has name => ( is => 'ro' );

    template page => sub {
        html { 
            head { title { 'Example' } };
            show( 'body' );
        }
    };

    template body => sub {
        my $self = shift;

        body { 
            h1 { 'howdie ' . $self->name } 
        }
    };

    package main;

    my $template = MyTemplate->new( name => 'Bob' );
    print $template->render('page');

=head1 DESCRIPTION

WARNING: Codebase is alpha with extreme prejudice. Assume that bugs are
teeming and that the API is subject to change.

L<Template::Caribou> is a L<Moose>-based, class-centric templating system
mostly aimed at producing sgml-like outputs (HTML, XML, SVG, etc). It is
heavily inspired by L<Template::Declare>.

=head1 SEE ALSO

L<http://babyl.dyndns.org/techblog/entry/caribou>  - The original blog entry
introducing L<Template::Caribou>.

L<Template::Declare>

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

