package Template::Caribou::Role;
# ABSTRACT: Caribou core engine

=head1 SYNOPSIS

    package MyTemplate;

    use Moose;

    with 'Template::Caribou::Role';

    has name => ( is => 'ro' );

    use Template::Caribou::Utils qw/ template /;

    template greetings => sub {
        my $self = shift;

        print "hello there, ", $self->name;
    };

    # later on...
    
    my $template =  MyTemplate->new( name => 'Yanick' );

    print $template->render('greetings');


=head1 DESCRIPTION

This role implements the rendering core of Caribou, which mostly deals
with defining the templates of a class and calling them.

=head2 The templates

The templates are coderefs expected to print or return the content they are generating.

When called by C<render> or C<show>, a coderef will be passed the template object and any
arguments given to C<render>/C<show>. 

    package MyTemplate;

    use Template::Caribou;

    has name => ( is => 'ro' );

    template greetings => sub {
        my( $self, %args ) = @_;

        'hi there ' . $self->name . '!' x $args{excited};
    };

    my $bou = MyTemplate->new( name => 'Yanick' );

    print $bou->render('greetings'); 
        # prints 'hi there Yanick'

    print $bou->render('greetings', excited => 1);
        # print 'hi there Yanick!

In addition of those arguments, the file descriptions
C<::STDOUT> and C<::RAW> are locally defined. Anything printed to C<::RAW> is added verbatim to the
content of the template, whereas something printed to C<STDOUT> will be HTML-escaped. 
If nothing has been printed at all by the template, its return value will be considered to be 
its generated content.

    # prints '&lt;hey>'
    print MyTemplate->render(sub{
        print "<hey>";
    });
    
    # prints '<hey>'
    print MyTemplate->render(sub{
        print ::RAW "<hey>";
    });

    # prints 'onetwo'
    print MyTemplate->render(sub{
        print "one";
        print "two";
    });
    
    # prints 'one'
    print MyTemplate->render(sub{
        print "one";
        return "ignored";
    });
    
    # prints 'no print, not ignored'
    print MyTemplate->render(sub{
        return "not print, not ignored";
    });

=head2 Definiting templates for single instances

Template are usually defined for the class. I.e.,

    package MyTemplate;

    use Template::Caribou;

    template foo => sub { 'foo' };

    my $instance_a = MyTemplate->new;

    $instance_a->set_template( bar => sub { 'bar' } );

    my $instance_b = MyTemplate->new;

    say 'has it' if $instance_b->get_template( 'bar' ); # prints 'has it'

Typically, extending the templates can be done by creating subclasses inheriting from
the main one. If you want to add templates to a single object instance instead, that's possible by creating an
anonymous class inheriting from the main class. The helper class method C<anon_instance> can help you with that:


    my $instance_c = MyTemplate->anon_instance( %new_arguments );
    $instance_c->set_template( baz => sub { 'baz' } );

    say 'has it' if $instance_c->get_template( 'bar' ); # prints 'has it'

    say 'has it' if $instance_c->get_template( 'baz' ); # prints 'has it'

    say 'has it' if $instance_b->get_template( 'baz' ); # doesn't print

=cut

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
    is      => 'ro',
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

=method indent( $bool )

Accessor to the indent attribute. Indicates if the tags rendered 
within the templates should be pretty-printed with indentation or not. 
Defaults to C<true>.

=cut

=method set_template( $name => sub { ... } )

Sets the given template.

=cut

sub set_template($self,$name,$value) {
    $self->meta->add_method( "template $name" => $value );
}

=method get_template( $name )

Returns the requested template, or nothing it does not exist.

=cut

sub get_template($self,$name) {
    return eval {
        $self->meta->find_method_by_name( "template $name" )->body
    };
}

=method all_templates

Returns the names of all templates available to the object, sorted
alphabetically.

=cut

sub all_templates($self) {
    return 
        sort
        map { /^template (.*)/ } 
            $self->meta->get_method_list;
}

=method anon_instance(@args_for_new)

Creates an anonymous class inheriting from the current one and builds an object instance
with the given arguments. Useful when wanting to define templates for one specific instance.

=cut

sub anon_instance($class,@args) {
    Class::MOP::Class
        ->create_anon_class(superclasses => [ $class ])
        ->new_object( can_add_templates => 1, @args);
}

=method formatter( $formatter ) 

Accessor for the object formatter. If a formatter is given to the object, the output of
C<render> will be groomed by it before being returned.

The formatter must be an instance of a class 
consuming the L<Template::Caribou::Formatter> role. It can also be a string, in which case
the string will be taken as the name of the class of the formatter. The namespace 'Template::Caribou::Formatter::'
will be prepended to the name, unless it begins with a '+'.

    # all equivalent

    $bou->formatter( 'Twig' );

    $bou->formatter( '+Template::Caribou::Formatter::Twig' );

    my $formatter = Template::Caribou::Formatter::Twig->new;
    $bou->formatter($formatter);

=method has_formatter

Returns C<true> if the object has a formatter.

=cut

=method import_template_dir( $directory )

Imports all the files with a C<.bou> extension in I<$directory>
as templates (non-recursively).  

Returns the name of the imported templates.

=cut

sub import_template_dir($self,$directory) {

   $directory = path( $directory );

   return map {
        $self->import_template("$_")      
   } grep { $_->is_file } $directory->children( qr/\.bou$/ );
}

=method render( $template, @template_args )

Renders the given C<$template>, passing it the C<@template_args>, and returns 
its generated output. 
The C<$template> can be a template name, or an anonymous sub.

    print $bou->render( 'greetings' => { friendly => 1 } );

    print $bou->render( sub {
        my( $self, $name ) = @_;

        'hi ' . $name . "\n";
    }, $_ ) for @friends; 

=cut

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

    $DB::single = $::NOW;
    
    # called in a void context and inside a template => print it
    print ::RAW $output if $Template::Caribou::IN_RENDER;

    return $output;
}

sub _render ($self, $method, @args) {
    local $Template::Caribou::TEMPLATE = $self;
            
    local $Template::Caribou::IN_RENDER = 1;
    local $Template::Caribou::OUTPUT;

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

=head1 SEE ALSO

L<http://babyl.dyndns.org/techblog/entry/caribou>  - The original blog entry
introducing L<Template::Caribou>.

L<Template::Declare>

=cut



