package Template::Caribou::Files;

use strict;
use warnings;

use Path::Class;
use Method::Signatures;

use MooseX::SemiAffordanceAccessor;
use Moose::Role;
use List::Pairwise qw/ mapp /;

has template_dirs => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
    trigger => \&load_template_dirs,
);

sub load_template_dirs {
    my( $self ) = @_;

    for my $dir ( map { dir($_) }  @{ $self->template_dirs } ) {
        $dir->recurse( callback => sub{ 
             return unless $_[0] =~ /\.bou$/;
             my $f = $_[0]->relative($dir)->stringify;
             $f =~ s/\.bou$//;
             $self->import_template_file( $f => $_[0] );
        });
    }

}


sub BUILD {
    my $self = shift;
    $self->load_template_dirs;
}

has template_files => (
    traits => [ 'Hash' ],
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
    handles => {
        set_template_file => 'set',
        template_files_mapping => 'elements',
    },
);

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
    warn $class;

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
    $self->set_template_file( $name => [ $file => $file->stat->mtime ] );

    return $name;
}

method refresh_template_dirs {

    my %seen = mapp { $b->[0] => $b->[1] } $self->template_files_mapping;

    for my $dir ( map { dir($_) }  @{ $self->template_dirs } ) {
        $dir->recurse( callback => sub{ 
             return unless $_[0] =~ /\.bou$/;

             return if $seen{"$_[0]"} >= $_[0]->stat->mtime;

             my $f = $_[0]->relative($dir)->stringify;

             $f =~ s/\.bou$//;
             $self->import_template_file( $f => $_[0] );
        });
    }

}

method refresh_template_files {
    $self->refresh_template_dirs;
}

1;
