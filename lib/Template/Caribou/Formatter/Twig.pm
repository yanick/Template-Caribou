package Template::Caribou::Formatter::Twig;
BEGIN {
  $Template::Caribou::Formatter::Twig::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Formatter::Twig::VERSION = '0.2.3';
}

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

__END__

=pod

=head1 NAME

Template::Caribou::Formatter::Twig

=head1 VERSION

version 0.2.3

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
