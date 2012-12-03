package Template::Caribou::Formatter::Twig;

use strict;
use warnings;

use XML::Twig;

use Moose;

with 'Template::Caribou::Formatter';

has parser => (
    is => 'ro',
    isa => 'XML::Twig',
    default => sub {
        XML::Twig->new(
            pretty_print => 'indented_close_tag',
            empty_tags   => 'html',
        );
    },
);

sub format {
    my( $self, $input ) = @_;

    my $output;

    open my $fh, '>', \$output;

    eval {
        $self->parser->parse($input)->print($fh);
    };

    # if we failed, let's at least return the dirty version
    return $@ ? $input : $output;
}

1;
