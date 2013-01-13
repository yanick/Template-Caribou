package Template::Caribou::Files;

use strict;
use warnings;

use Path::Class;
use Method::Signatures;

use MooseX::SemiAffordanceAccessor;
use Moose::Role;
use List::Pairwise qw/ mapp /;

=method import_template_file( $name => $file )

Imports the content of I<$file> as a template. If I<$name> is not given, 
it is assumed to be the basename of the file, minus the extension. 

Returns the name of the imported template.

=cut

sub import_template_file {
    my $self = shift;

    my( $name, $file ) = @_ == 2 ? @_ : ( undef, @_ );

    $file = file($file) unless ref $file;

    ( $name = $file->basename ) =~ s/\..*?$// unless $name;

    my $class = ref( $self ) || $self;

    my $sub = eval <<"END_EVAL";
package $class;
use Method::Signatures;
method {
# line 1 "@{[ $file->absolute ]}"
    @{[ $file->slurp ]}
}
END_EVAL

    die $@ if $@;
    $self->set_template( $name => $sub );

    return $name;
}

method import_template_dirs ( @dirs ) {

    for my $dir ( map { dir($_) }  @dirs ) {
        $dir->recurse( callback => sub{ 
             return unless $_[0] =~ /\.bou$/;
             my $f = $_[0]->relative($dir)->stringify;
             $f =~ s/\.bou$//;
             $self->import_template_file( $f => $_[0] );
        });
    }

}



1;
