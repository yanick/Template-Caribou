package Template::Caribou::Role;
# ABSTRACT: Caribou core engine


use 5.20.0;
use strict;
use warnings;
no warnings qw/ uninitialized /;

use Carp;
use Moose::Role;
use Template::Caribou::Utils;

use Path::Tiny;

use Template::Caribou::Tags;

use List::AllUtils qw/ uniq any /;

use Moose::Exporter;
Moose::Exporter->setup_import_methods(
    as_is => [ 'template' ],
);

use experimental 'signatures';

has indent => (
    is      => 'rw',
    default => 1,
);

has can_add_templates => (
    is => 'rw',
);

sub template {
    my $class = shift;

    # cute way to say $self might or might not be there
    my( $coderef, $name, $self ) = reverse @_;

    if ( $self ) {
        local $Carp::CarpLevel = 1;
        croak "can only add templates from instances created via 'anon_instance' ",
            "or with the attribute 'can_add_templates'" unless $self->can_add_templates;

        $class = $self->meta;
    }

    carp "redefining '$name'" 
        if $class->can('get_all_method_names') and any { $name eq $_ } $class->get_all_method_names;
    carp "redefining '$name'" if $class->name->can($name);


    $class->add_method( $name => sub {
        my( $self, @args ) = @_;
        if( defined wantarray ) {
            return $self->render( $coderef, @args );
        }
        else {
            # void context
            $self->render( $coderef, @args );
            return;
        }
    });
}



sub anon_instance($class,@args) {
    Class::MOP::Class
        ->create_anon_class(superclasses => [ $class ])
        ->new_object( can_add_templates => 1, @args);
}

sub get_render {
    my ( $self, $template, @args ) = @_;
    local $Template::Caribou::IN_RENDER;
    return $self->render($template,@args);
}

sub render {
    my ( $self, $template, @args ) = @_;

    # 0.1 is true, and yet will round down to '0' for the first indentation
    local $Template::Caribou::TAG_INDENT_LEVEL 
        = $Template::Caribou::TAG_INDENT_LEVEL // 0.1 * !! $self->indent;

    my $output = $self->_render($template,@args);

    # if we are still within a render, we turn the string
    # into an object to say "don't touch"
    $output = Template::Caribou::String->new( $output ) 
        if $Template::Caribou::IN_RENDER;

    # called in a void context and inside a template => print it
    print ::RAW $output if $Template::Caribou::IN_RENDER;

    return $output;
}

sub _render ($self, $method, @args) {
    local $Template::Caribou::TEMPLATE = $self;
            
    local $Template::Caribou::IN_RENDER = 1;
    local $Template::Caribou::OUTPUT;

    unless(ref $method) {
        $method = $self->can($method)
            or die "no template named '$method' found\n";
    }

    local *STDOUT;
    local *::RAW;
    tie *STDOUT, 'Template::Caribou::Output';
    tie *::RAW, 'Template::Caribou::OutputRaw';

    select STDOUT;

    my $res = $method->( $self, @args );

    return( $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res ) );
}

1;




