package Template::Caribou::DevServer;

use strict;
use warnings;

use Dancer;

use Moose::Role;

sub dev_server {
    my $self = shift;

    set show_errors => 1;

    my %seen;

    hook before => sub { 
        #$self->refresh_template_files if $self->does('Template::Caribou::File');

        for my $t ( grep { !$seen{$_} } $self->all_templates ) {
            warn "adding template $t\n";
            get "/$t" => sub { $self->render( $t => %{params()} ) };
            $seen{$t}++;
        }
    };

    for my $t ( grep { !$seen{$_} } $self->all_templates ) {
        warn "adding template $t\n";
        get "/$t" => sub { $self->render( $t => %{params()} ) };
        $seen{$t}++;
    }


    dance;
}

1;
