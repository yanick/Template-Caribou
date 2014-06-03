package Template::Caribou::Formatter;
BEGIN {
  $Template::Caribou::Formatter::AUTHORITY = 'cpan:YANICK';
}
$Template::Caribou::Formatter::VERSION = '0.2.4';
use strict;
use warnings;

use Moose::Role;

requires 'format';

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Template::Caribou::Formatter

=head1 VERSION

version 0.2.4

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
