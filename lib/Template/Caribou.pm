package Template::Caribou;

use strict;
use warnings;
no warnings qw/ uninitialized /;

use Moose::Role;
use Template::Caribou::Utils;

sub add_template {
    my ( $self, $label, $sub ) = @_;

    template( $self->meta, $label, $sub );
}

sub render {
    my ( $self, $template, @args ) = @_;

    my $method = "template_$template";

    my $output = do
    {
        local $Template::Caribou::TEMPLATE =
            $Template::Caribou::TEMPLATE || $self;
            
        local $Template::Caribou::IN_RENDER = 1;
        local *STDOUT;
        local *::RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';
        my $res = $self->$method( @_ );

        $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    $output = Template::Caribou::String->new( $output );

    print $output unless defined wantarray or $Template::Caribou::IN_RENDER;

    return $output;
}

1;



