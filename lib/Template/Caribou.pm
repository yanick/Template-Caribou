package Template::Caribou;
# ABSTRACT: class-based HTML-centric templating system


use Moose::Util qw/ apply_all_roles is_role /;

use Template::Caribou::Utils;

sub import {
    my $class = caller;

    unless ( $class->isa('Moose::Object') or is_role($class) ) {
        eval "package $class; use Moose;";
    }

    eval <<"END_EVAL";
        package $class; 
        use Template::Caribou::Utils qw/ show template attr /;
END_EVAL

    die $@ if $@;

    $class = Class::MOP::class_of($class);
    apply_all_roles($class,'Template::Caribou::Role');
}

1;
