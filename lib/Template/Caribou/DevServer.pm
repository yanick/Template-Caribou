package Template::Caribou::DevServer;

use strict;
use warnings;

use Dancer 2;

use Moose::Role;

has 'public_dir' => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

sub dev_server {
    my $self = shift;

    set show_errors => 1;

    my %seen;

    config->{route_handlers}{File}{public_dir} =
    config->{public_dir} = $self->public_dir;

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
        get "/$t" => sub { $DB::single = 1; $self->render( $t => %{params()} ) };
        $seen{$t}++;
    }


    dance;
}

1;
