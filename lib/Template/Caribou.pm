package Template::Caribou;
# ABSTRACT: class-based HTML-centric templating system

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

=cut
use Moose::Util qw/ apply_all_roles is_role /;

use Template::Caribou::Utils;

sub import {
    my $class = caller;

    unless ( $class->isa('Moose::Object') or is_role($class) ) {
        eval "package $class; use Moose;";
    }

    eval "package $class; use Template::Caribou::Utils;";

    $class = Class::MOP::class_of($class);
    apply_all_roles($class,'Template::Caribou::Role');
}

1;

__END__

Moose::Exporter->setup_import_methods(
    also => 'Template::Caribou::Utils',
    meta_lookup => sub {
        my $class = shift;

        unless ( $class->isa('Moose::Object') or is_role($class) ) {
            eval "package $class; use Moose;";
        }

        $class = Class::MOP::class_of($class);
        apply_all_roles($class,'Template::Caribou::Role');
        return $class;
    },
);


1;
