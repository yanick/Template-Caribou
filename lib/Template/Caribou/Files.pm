package Template::Caribou::Files;
BEGIN {
  $Template::Caribou::Files::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Files::VERSION = '0.2.2';
}
#ABSTRACT: Role to load templates from files


use strict;
use warnings;

use MooseX::Role::Parameterized;

parameter dirs => (
    traits => [ 'Array' ],
    isa => 'ArrayRef',
    default => sub { [] },
    handles => {
        all_dirs => 'elements',
    },
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

    has template_dirs => (
        traits => [ 'Array' ],
        isa => 'ArrayRef',
        builder => '_build_template_dirs',
        handles => {
            all_template_dirs => 'elements',
            add_template_dirs => 'push',
        },
    );

    sub _build_template_dirs { [] }

    around _build_template_dirs => sub {
        my( $ref, $self ) = @_;

        return [ @{ $ref->($self) }, $p->all_dirs ];
    };

    before 'render' => sub {
        $_[0]->import_template_dirs( @{$p->dirs} ) #@{ $_[0]->template_dirs } ) 
            if not $Template::Caribou::IN_RENDER;
    } if $p->auto_reload;


method import_template_file => \&_import_template_file;

sub _import_template_file {
    my $self = shift;

    my( $name, $file ) = @_ == 2 ? @_ : ( undef, @_ );

    $file = file($file) unless ref $file;

    ( $name = $file->basename ) =~ s/\..*?$// unless $name;

    my $class = ref( $self ) || $self;

    my $lines = $file->slurp;

    my $signature = $lines =~ m{^#\((.*)\)\s*$}m ? $1 : '';

    my $code = <<"END_EVAL";
package $class;
use Method::Signatures;
method ($signature) {
# line 1 "@{[ $file->absolute ]}"
$lines
}
END_EVAL

    my $sub = eval $code;

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

__END__

=pod

=head1 NAME

Template::Caribou::Files - Role to load templates from files

=head1 VERSION

version 0.2.2

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
all template file (i.e., all files with a C<.bou> extension) under the given directories.

The names of the imported templates will be their path, relative to the
imported directories, without their extension. To take the example in the
L</SYNOPSIS>, if the content of C<my_templates/> is:

    ./foo.bou
    ./bar.bou
    ./baz/frob.bou

then the templates C<foo.bou>, C<bar.bou> and C<baz/frob> will be created.

=head1 METHODS

=head2 import_template_file( $name => $file )

Imports the content of I<$file> as a template. If I<$name> is not given, 
it is assumed to be the basename of the file, minus the extension. 

Returns the name of the imported template.

=head1 ROLE PARAMETERS

=head2 dirs

The array ref of directories to scan for templates. 

=head2 auto_reload

If set to true, the import directories will be rescanned and every file
re-imported before every call to C<render>. Useful during development.

Defaults to false.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
