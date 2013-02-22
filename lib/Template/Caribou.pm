package Template::Caribou;
BEGIN {
  $Template::Caribou::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::VERSION = '0.2.0';
}
# ABSTRACT: class-based HTML-centric templating system


use strict;
use warnings;
no warnings qw/ uninitialized /;

use Carp;
use Moose::Role;
use MooseX::SemiAffordanceAccessor;
use MooseX::ClassAttribute;
use Template::Caribou::Utils;
use Path::Class qw/ file dir /;
use Method::Signatures;

use Template::Caribou::Tags;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    as_is => [ 'template', 'attr', 'show' ],
);

func template( $name, $code ) {
    my $class = caller(0);
    $class->set_template( $name => $code );
}



use Moose::Util::TypeConstraints;

role_type 'Formatter', { 
    role => 'Template::Caribou::Formatter' 
};

coerce Formatter 
    => from 'Str' => via {
    s/^\+/Template::Caribou::Formatter::/;
    eval "use $_; 1" 
        or die "couldn't load '$_': $@";

    $_->new;
};

has formatter => (
    is => 'rw',
    does => 'Formatter',
    predicate => 'has_formatter',
    clearer => 'clear_formatter',
    handles => 'Template::Caribou::Formatter',
    coerce => 1,
);

method set_template($name,$value) {
    $self->meta->add_method( "template $name" => $value );
}

method t($name) {
    my $method = $self->meta->get_method( "template $name" )
        or die "template '$name' not found\n";
    return $method->body;
}

method all_templates {
    return 
        sort
        map { /\s(.*)/ }
        grep { /^template / } $self->meta->get_method_list;
}



method import_template_dir($directory) {

   $directory = dir( $directory );

   return map {
        $self->import_template("$_")      
   } grep { $_->basename =~ /\.bou$/ } grep { -f $_ } $directory->children;
}

sub add_template {
    my ( $self, $label, $sub ) = @_;

    $self->set_template( $label => $sub );
}

sub render {
    my ( $self, $template, @args ) = @_;

    my $method = ref $template eq 'CODE' ? $template : $self->t($template);

    my $output = do
    {
        local $Template::Caribou::TEMPLATE = $self;
        #$Template::Caribou::TEMPLATE || $self;
            
        local $Template::Caribou::IN_RENDER = 1;
        local *STDOUT;
        local *::RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';
        my $res = $method->( $self, @args );

        $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    # if we are still within a render, we turn the string
    # into an object to say "don't touch"
    $output = Template::Caribou::String->new( $output ) 
        if $Template::Caribou::IN_RENDER;

    $DB::single = 1;

    print ::RAW $output if $Template::Caribou::IN_RENDER and not defined wantarray;

    if( !$Template::Caribou::IN_RENDER and $self->has_formatter ) {
        $output = $self->format($output);
    }

    return $output;
}


sub show {
    croak "'show()' must be called from within a template"
        unless $Template::Caribou::IN_RENDER;

    print ::RAW $Template::Caribou::TEMPLATE->render( @_ );
}

1;

__END__

=pod

=head1 NAME

Template::Caribou - class-based HTML-centric templating system

=head1 VERSION

version 0.2.0

=head1 SYNOPSIS

    package MyTemplate;

    use Moose;
    use Template::Caribou;

    with 'Template::Caribou';

    use Template::Caribou::Tags::HTML qw/ :all /;

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

    my $template = MyTemplate->new( name => 'Yanick' );
    print $template->render('page');

=head1 DESCRIPTION

WARNING: Codebase is alpha with extreme prejudice. Assume that bugs are
teeming and that the API is subject to change.

L<Template::Caribou> is a L<Moose>-based, class-centric templating system
mostly aimed at producing sgml-like outputs, mostly HTML, but also XML, SVG, etc. It is
heavily inspired by L<Template::Declare>.

For a manual on how to use C<Template::Caribou>, have a peek at
L<Template::Caribou::Manual>.

=head1 METHODS

=head2 pretty_render()

Returns true if rendered templates are passed through the prettifier.

=head2 enable_pretty_render( $bool )

if set to true, rendered templates will be filtered by a prettifier 
before being returned by the C<render()> method.

=head2 import_template_dir( $directory )

Imports all the files with a C<.bou> extension in I<$directory>
as templates (non-recursively).  

Returns the name of the imported templates.

=head2 show( $template, @args )

Outside of a template, behaves like C<render()>. In a template, prints out
the result of the rendering in addition of returning it.

=head1 SEE ALSO

L<http://babyl.dyndns.org/techblog/entry/caribou>  - The original blog entry
introducing L<Template::Caribou>.

L<Template::Declare>

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
