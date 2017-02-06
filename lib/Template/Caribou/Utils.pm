package Template::Caribou::Utils;
# ABSTRACT: internal utilities for Template::Caribou

=head1 DESCRIPTION

Used internally by L<Template::Caribou>. Nothing interesting
for end-users.

=cut

use strict;
use warnings;
no warnings qw/ uninitialized /;

BEGIN {
    *::RAW = *::STDOUT;
}

use parent 'Exporter::Tiny';

use experimental 'signatures';

use Carp;


package
    Template::Caribou::String;

use overload 
    '""' => sub { return ${$_[0] } },
    'eq' => sub { ${$_[0]} eq $_[1] };

sub new { my ( $class, $string ) = @_;  bless \$string, $class; }


package 
    Template::Caribou::Output;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub escape {
    no warnings qw/ uninitialized/;
    @_ = map { 
        my $x = $_;
        $x =~ s/&/&amp;/g;
        $x =~ s/</&lt;/g;
        $x;
    } @_;

    return wantarray ? @_ : join '', @_;
}

sub PRINT { shift; print ::RAW escape( @_ ) } 

package
    Template::Caribou::OutputRaw;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub PRINT { 
    shift;
    no warnings qw/ uninitialized /;
    $Template::Caribou::OUTPUT .= join '', @_, $\;
} 

1;



