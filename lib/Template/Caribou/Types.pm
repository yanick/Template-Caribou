package Template::Caribou::Types;

use strict;
use warnings;

use Class::Load qw/ load_class /;

use Type::Library -base;

use Types::Standard qw/ Str Object /;

my $FORMATTER = 'Type::Tiny'->new(
    name => 'Formatter',
    constraint => sub { $_->DOES('Template::Caribou::Formatter') },
    message => sub { "$_ must consume the Template::Caribou::Formatter role" },
);

$FORMATTER = $FORMATTER->plus_coercions(
    Str() => sub {
        $_ = "Template::Caribou::Formatter::$_" unless s/^\+//;
        load_class($_)->new;
    },
);

__PACKAGE__->meta->add_type($FORMATTER);

__PACKAGE__->meta->make_immutable;

1;


