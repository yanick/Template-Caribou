package Template::Caribou;
# ABSTRACT: class-based HTML-centric templating system

use Carp;

use Moose::Exporter;

use Template::Caribou::Role;
use Template::Caribou::Tags qw/ attr /;

Moose::Exporter->setup_import_methods(
    with_meta => [ 'template' ],
    as_is     => [ 'attr', 'show' ],
    also      => [ 'Template::Caribou::Role' ],
);

use Moose::Util qw/ apply_all_roles /;

use 5.10.0;

sub show {
    state $shown_warning = 0;

    carp 'show() is deprecated, use $bou->my_template instead'
        unless $shown_warning++;

    $Template::Caribou::TEMPLATE->render(@_);
}

sub init_meta {
    my $class = shift;
    my %args = @_;

    my $meta = eval { $args{for_class}->meta };

    unless ( $meta ) {
        $meta = Moose->init_meta(@_);
        eval "package $args{for_class}; use Moose;";
    }

    apply_all_roles( $args{for_class}, 'Template::Caribou::Role' );

    return $meta;
}

1;
