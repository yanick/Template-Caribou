package Template::Caribou;
# ABSTRACT: class-based *ML-centric templating system

=head1 SYNOPSIS

    package MyTemplate;

    use Moose;
    with 'Template::Caribou';

    use Template::Caribou::Utils;
    use Template::Caribou::Tags::HTML;

    has name => ( is => 'ro' );

    template page => sub {
        html { 
            head { title { 'Example' } };
            show( 'body' );
        }
    };

    template body => sub {
        my $self = shift;

        body { 
            h1 { 'howdie ' . $self->name } 
        }
    };

    package main;

    my $template = MyTemplate->new( name => 'Bob' );
    print $template->render('page');

=head1 DESCRIPTION

WARNING: Codebase is alpha with extreme prejudice. Assume that bugs are
teeming and that the API is subject to change.

L<Template::Caribou> is a L<Moose>-based, class-centric templating system
mostly aimed at producing sgml-like outputs (HTML, XML, SVG, etc). It is
heavily inspired by L<Template::Declare>.

=cut

use strict;
use warnings;
no warnings qw/ uninitialized /;

use Moose::Role;
use MooseX::SemiAffordanceAccessor;
use MooseX::ClassAttribute;
use Template::Caribou::Utils;
use Path::Class qw/ file /;

class_has 'templates' => (
    isa => 'HashRef',
    traits => [ 'Hash' ],
    is => 'ro',
    default => sub { {} },
    handles => {
        t => 'get',
        set_template => 'set',
    },
);

=method pretty_render()

Returns true if rendered templates are passed through the prettifier.

=method enable_pretty_render( $bool )

if set to true, rendered templates will be filtered by a prettifier 
before being returned by the C<render()> method.

=cut

has pretty_render => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
    writer => 'enable_pretty_render',
);

has pretty_renderer => (
    is => 'rw',
    default => sub {
    sub{ 
        require XML::Twig;

        my $output;

        open my $fh, '>', \$output;

        my $twig = XML::Twig->new( pretty_print => 'indented_close_tag',
        empty_tags => 'html', 
        #output_filter => 'html'
        )->parse(shift)->print($fh);

        return $output;
    }},
);



sub set_template {
    my $self = shift;
    my( $name, $value ) = @_;

    $self->templates->{$name} = $value;
}

sub import_template {
    my $self = shift;
    my $file = file( shift );

    ( my $name = $file->basename ) =~ s/\..*?$//;

    my $class = $self;

    my $sub = eval <<"END_EVAL";
package $class;
sub {
# line 1 "@{[ $file->absolute ]}"
    @{[ $file->slurp ]}
}
END_EVAL

    die $@ if $@;

    $self->set_template( $name => $sub );
}

sub add_template {
    my ( $self, $label, $sub ) = @_;

    $self->set_template( $label => $sub );
}

sub render {
    my ( $self, $template, @args ) = @_;

    my $method = ref $template eq 'CODE' ? $template : $self->t($template);

    my $output = do
    {
        local $Template::Caribou::TEMPLATE = $self;
        #$Template::Caribou::TEMPLATE || $self;
            
        local $Template::Caribou::IN_RENDER = 1;
        local *STDOUT;
        local *::RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';
        my $res = $method->( $self, @args );

        $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    # if we are still within a render, we turn the string
    # into an object to say "don't touch"
    $output = Template::Caribou::String->new( $output ) 
        if $Template::Caribou::IN_RENDER;

    print ::RAW $output if $Template::Caribou::IN_RENDER and not defined wantarray;

    if( !$Template::Caribou::IN_RENDER and $self->pretty_render ) {
        $output = $self->pretty_renderer->( $output );
    }

    return $output;
}

1;

=head1 SEE ALSO

L<http://babyl.dyndns.org/techblog/entry/caribou>  - The original blog entry
introducing L<Template::Caribou>.

L<Template::Declare>

=cut


