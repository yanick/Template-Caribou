package Template::Caribou::DevServer;

use strict;
use warnings;

use Dancer;

use Moose::Role;

sub dev_server {
    my $self = shift;

    for my $t ( $self->all_templates ) {
        warn "adding template $t\n";

        get "/$t" => sub {
            $self->render( $t => %{params()} );
        };

    }

    hook before => sub { $self->refresh_template_files };

    dance;
}

1;
