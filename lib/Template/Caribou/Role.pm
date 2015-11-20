package Template::Caribou::Role;

use strict;
use warnings;
no warnings qw/ uninitialized /;

use Carp;
use Moose::Role;
use MooseX::ClassAttribute;
use Template::Caribou::Utils;
use Path::Class qw/ file dir /;

use Template::Caribou::Tags;
use Moose::Exporter;
use Moose::Util::TypeConstraints;

use experimental 'signatures';

use List::AllUtils qw/ uniq /;

use Template::Caribou::Types qw/ Formatter /;

has formatter => (
    isa => Formatter,
    coerce => 1,
    is => 'rw',
    predicate => 'has_formatter',
);

around render => sub {
    my( $orig, $self, @args ) = @_;
    my $result = $orig->($self,@args);

    if ( ! $Template::Caribou::IN_RENDER and $self->has_formatter ) {
        $result = $self->formatter->format($result);
    }

    return $result;
};



sub set_template($self,$name,$value) {
    $self->meta->add_method( "template $name" => $value );
}

sub get_template($self,$name) {
    my $method = $self->meta->find_method_by_name( "template $name" )
        or die "template '$name' not found\n";
    return $method->body;
}

sub all_templates($self) {
    return 
        sort
        map { /\s(.*)/ }
        grep { /^template / } $self->meta->get_method_list;
}


=method import_template_dir( $directory )

Imports all the files with a C<.bou> extension in I<$directory>
as templates (non-recursively).  

Returns the name of the imported templates.

=cut

sub import_template_dir($self,$directory) {

   $directory = dir( $directory );

   return map {
        $self->import_template("$_")      
   } grep { $_->basename =~ /\.bou$/ } grep { -f $_ } $directory->children;
}

sub add_template {
    my ( $self, $label, $sub ) = @_;

    $self->set_template( $label => $sub );
}

sub render {
    my ( $self, $template, @args ) = @_;

    my $method = ref $template eq 'CODE' ? $template : $self->get_template($template);

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
        select STDOUT;
        my $res = $method->( $self, @args );

        $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    # if we are still within a render, we turn the string
    # into an object to say "don't touch"
    $output = Template::Caribou::String->new( $output ) 
        if $Template::Caribou::IN_RENDER;

    print ::RAW $output if $Template::Caribou::IN_RENDER and not defined wantarray;

    return $output;
}

=method show( $template, @args )

Outside of a template, behaves like C<render()>. In a template, prints out
the result of the rendering in addition of returning it.

=cut

sub show {
    croak "'show()' must be called from within a template"
        unless $Template::Caribou::IN_RENDER;

    print ::RAW $Template::Caribou::TEMPLATE->render( @_ );
}

1;

=head1 SEE ALSO

L<http://babyl.dyndns.org/techblog/entry/caribou>  - The original blog entry
introducing L<Template::Caribou>.

L<Template::Declare>

=cut



