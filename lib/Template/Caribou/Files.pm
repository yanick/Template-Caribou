package Template::Caribou::Files;
#ABSTRACT: Role to load templates from files


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




};



1;
