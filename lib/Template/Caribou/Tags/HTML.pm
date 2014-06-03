package Template::Caribou::Tags::HTML;
BEGIN {
  $Template::Caribou::Tags::HTML::AUTHORITY = 'cpan:YANICK';
}
$Template::Caribou::Tags::HTML::VERSION = '0.2.4';
use strict;
use warnings;

use Template::Caribou::Utils;

BEGIN {
    @Template::Caribou::Tags::HTML::TAGS =  qw/
        p html head h1 h2 h3 h4 h5 h6 body emphasis div
        sup
        style title span li ol ul i b bold a 
        label link img section article
        table thead tbody table_row th td
        fieldset legend form input select option button
        small
        textarea
    /;
}

use Template::Caribou::Tags
    'render_tag',
    'attr',
    mytag => { -as => 'table_row', name => 'tr' },
    map { ( mytag => { -as => $_, name => $_ } ) }
        grep { !/table_row/ }
        @Template::Caribou::Tags::HTML::TAGS;

use Sub::Exporter -setup => {
    exports => [
        @Template::Caribou::Tags::HTML::TAGS
    ],
    groups => { default => ':all' },
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Template::Caribou::Tags::HTML

=head1 VERSION

version 0.2.4

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
