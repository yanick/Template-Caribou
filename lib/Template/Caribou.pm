package Template::Caribou;
# ABSTRACT: class-based HTML-centric templating system


use Moose::Util qw/ apply_all_roles is_role /;
use Template::Caribou::Utils qw/ attr /;

use Moose -traits => 'Template::Caribou::Trait';
use  Moose::Exporter;

with 'Template::Caribou::Role';

use Carp;

Moose::Exporter->setup_import_methods(
    with_meta => [ 'template' ],
    as_is => [ qw/ show attr / ],
    also => [  'Moose' ],
);

has can_add_templates => (
    is => 'ro',
);


sub init_meta {
    my $class = shift;
   Moose->init_meta( @_, base_class => 'Template::Caribou' );
}

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


    $class->add_method( $name => sub {
        my( $self, @args ) = @_;
        $self->render( $coderef, @args );
    });
}

=function show( $template, @args )

Must be called from inside a template. Prints out
the result of the rendering in addition of returning it.

    template foo => sub {

        print "yadah";

        show( 'bar' );

        print "yadah";
    };

=cut

sub show {
    croak "'show()' must be called from within a template"
        unless $Template::Caribou::IN_RENDER;

    print ::RAW $Template::Caribou::TEMPLATE->render( @_ );
}

1;
