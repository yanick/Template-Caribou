package Template::Caribou::Files;

use strict;
use warnings;

use MooseX::Role::Parameterized;

parameter dirs => (
    isa => 'ArrayRef',
    default => sub { [] },
);

parameter auto_reload => (
    isa => 'Bool',
    default => 0,
);

role {
    use Path::Class;
    use List::Pairwise qw/ mapp /;

    use MooseX::ClassAttribute;
    use MooseX::SemiAffordanceAccessor;

    my $p = shift;

    my %arg = @_;

    before 'render' => sub {
        $_[0]->import_template_dirs( @{$p->dirs} ) #@{ $_[0]->template_dirs } ) 
            if not $Template::Caribou::IN_RENDER;
    } if $p->auto_reload;

=method import_template_file( $name => $file )

Imports the content of I<$file> as a template. If I<$name> is not given, 
it is assumed to be the basename of the file, minus the extension. 

Returns the name of the imported template.

=cut

method import_template_file => \&_import_template_file;

sub _import_template_file {
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

method import_template_dirs => \&_import_template_dirs; 

sub _import_template_dirs {
    my ( $self, @dirs ) = @_;

    for my $dir ( map { dir($_) }  @dirs ) {
        $dir->recurse( callback => sub{ 
             return unless $_[0] =~ /\.bou$/;
             my $f = $_[0]->relative($dir)->stringify;
             $f =~ s/\.bou$//;
             _import_template_file( $self, $f => $_[0] );
        });
    }

};

    _import_template_dirs( $arg{consumer}->name, @{$p->dirs} );

};



1;
