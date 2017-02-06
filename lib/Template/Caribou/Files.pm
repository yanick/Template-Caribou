package Template::Caribou::Files;
#ABSTRACT: Role to load templates from files

=head1 SYNOPSIS

    package MyTemplate;

    use Moose;

    with 'Template::Caribou';
    with 'Template::Caribou::Files' => {
        dirs => [ 'my_templates/' ],
        auto_reload => 1,
    };

    1;

=head1 DESCRIPTION

With I<Template::Caribou::Files>, a Caribou class will automatically import
all template files (i.e., all files with a C<.bou> extension) under the given directories.

The names of the imported templates will be their path, relative to the
imported directories, without their extension. To take the example in the
L</SYNOPSIS>, if the content of C<my_templates/> is:

    ./foo.bou
    ./bar.bou
    ./baz/frob.bou

then the templates C<foo.bou>, C<bar.bou> and C<baz/frob> will be created.

=head1 ROLE PARAMETERS

=head2 dirs

The array ref of directories to scan for templates. 

=head2 auto_reload

If set to true, the import directories will be rescanned and every file
re-imported before every call to C<render>. Useful during development.

Defaults to false.

=cut

use strict;
use warnings;

use MooseX::Role::Parameterized;

use Module::Runtime qw/ module_notional_filename /;
use Path::Tiny;
use Try::Tiny;

use experimental 'postderef';

parameter dirs => (
    default => undef,
);

parameter intro => (
    default => sub { [] },
);

    sub _load_template_file {
        my $self = shift;
        my $target = shift;

        my( $name, $file ) = @_ == 2 ? @_ : ( undef, @_ );

        $file = path($file);

        unless( $name ) {
            $name = $file->basename =~ s/\.bou//r;
        }

        my $class = ref $target || $target;

        my $code = join "\n",
            "package $class;",
            $self->intro->@*,
            "# line 1 ". $file,
            $file->slurp;

        my $coderef = eval $code;
        die $@ if $@;

        Template::Caribou::Role::template( (ref $target ? ( $target->meta, $target ) : $target->meta), $name, $coderef );
    };


    sub _load_template_dir {
        my ( $self, $target, $dir ) = @_;

        $dir = path($dir);

        Template::Caribou::Files::_load_template_file($self,$target,$_) for $dir->children( qr/\.bou$/ );
    };


role {
    my $p = shift;
    my %arg = @_;

    has template_dirs => (
        traits => [ 'Array' ],
        isa => 'ArrayRef',
        builder => '_build_template_dirs',
        handles => {
            all_template_dirs => 'elements',
            add_template_dirs => 'push',
        },
    );

    my $intro = $p->intro;
    has file_intro => (
        is => 'ro',
        default => sub { $intro },
    );

    my $dirs = $p->dirs;

    unless ( $dirs ) {
        my $name = $arg{consumer}->name;

        try {
            my $path = path( $INC{ module_notional_filename( $name )} =~ s/\.pm$//r );
            die unless $path->is_dir;
            $dirs = [ $path ];
        } catch {
            die "can't find directory for module '$name'";
        };
    }

    # so that we can call the role many times,
    # and the defaults will telescope into each other
    sub _build_template_dirs { [] }

    around _build_template_dirs => sub {
        my( $ref, $self ) = @_;

        return [ @{ $ref->($self) }, @$dirs ];
    };

    $DB::single = 1;
    

    Template::Caribou::Files::_load_template_dir( $p, $arg{consumer}->name, $_) for @$dirs;

    method add_template_file => sub {
        my( $self, $file ) = @_;
        $file = path($file);

        Template::Caribou::Files::_load_template_file(
            $p,
            $self,
            $file
        );
    };


=method import_template_file( $name => $file )

Imports the content of I<$file> as a template. If I<$name> is not given, 
it is assumed to be the basename of the file, minus the extension. 

Returns the name of the imported template.

=cut


};



1;
