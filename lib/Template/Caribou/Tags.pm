package Template::Caribou::Tags;
#ABSTRACT: generates tags functions for Caribou templates

=head1 SYNOPSIS

    package MyTemplate;

    use Template::Caribou;

    use Template::Caribou::Tags
        mytag => { -as => 'foo', tag => 'p', class => 'baz' };

    template bar => sub {
        foo { 'hello' };
    };

    # <p class="baz">hello</p>
    print __PACKAGE__->new->render('bar');

=head1 DESCRIPTION

This module provides the tools to create tag libraries, or ad-hoc tags.
For pre-defined sets of tags, you may want to look at L<Template::Caribou::Tags::HTML>,
L<Template::Caribou::Tags::HTML::Extended>, and friends.

=head2 Core functionality

Tag functions are created using the C<render_tag> function. For example:

    package MyTemplate;

    use Template::Caribou;

    use Template::Caribou::Tags qw/ render_tag /;

    sub foo(&) { render_tag( 'foo', shift ) }

    # renders as '<foo>hi!</foo>'
    template main => sub {
        foo { 
            "hi!";
        };
    };   

=head2 Creating ad-hoc tags

Defining a function and using C<render_tag> is a little bulky and, typically, will only be used when creating
tag libraries. In most cases, 
the C<my_tag> export keyword can be used to create custom tags. For example, the
previous C<foo> definition could have been done this way:

    package MyTemplate;

    use Template::Caribou;

    use Template::Caribou::Tags
        mytag => { tag => 'foo' };

    # renders as '<foo>hi!</foo>'
    template main => sub {
        foo { 
            "hi!";
        };
    };   
    


=head1 EXPORTS

The functions C<render_tag> and C<attr> (from L<Template::Caribou::Utils>) can be exported by this module. 
This module doesn't export any function by default. 

Custom tag functions can also be defined via the export keyword C<mytag>.

C<mytag> accepts the following arguments:

=over

=item tag => $name

Tagname that will be used. If not specified, defaults to C<div>.


=item -as => $name

Name under which the tag function will be exported. If not specified, defaults to the 
value of the C<tag> argument. At least one of C<-as> or C<tag> must be given explicitly.

=item groom => sub { }

Grooming function for the tag block. See C<render_tag> for more details.

=item class => $classes

Default value for the 'class' attribute of the tag.

    use Template::Caribou::Tags 
                    # <div class="main">...</div>
        mytag => { -as => 'main_div', class => 'main' };


=item attr => \%attributes

Default set of attributes for the tag.

    use Template::Caribou::Tags 
                    # <input disabled="disabled">...</input>
        mytag => { -as => 'disabled_input', tag => 'input', attr => { disabled => 'disabled' } };

=back


=cut

use strict;
use warnings;

use Carp;

use Template::Caribou::Role;

use parent 'Exporter::Tiny';
use experimental 'signatures';


our @EXPORT_OK = qw/ render_tag mytag attr /;

=function attr( $name => $value )

Accesses the attributes of a tag within its block.

If provided an even number of parameters, sets the attributes to those values.


    div {
        attr class => 'foo', 
             style => 'text-align: center';

        "hi there";
    };

    # <div class="foo" style="text-align: center">hi there</div>
    
Many calls to C<attr> can be done within the same block.

    div {
        attr class => 'foo';
        attr style => 'text-align: center';

        "hi there";
    };

    # <div class="foo" style="text-align: center">hi there</div>
  
To add to an attribute instead of replacing its value, prefix the attribute name
with a plus sign.

    div {
        attr class    => 'foo';

        attr '+class' => 'bar';

        "hi there";
    };

    # <div class="foo bar">hi there</div>
   
The value of an attribute can also be queried by passing a single argument to C<attr>.

    div { 
        ...; # some complex stuff here

        my $class = attr 'class';

        attr '+style' => 'text-align: center' if $class =~ /_centered/;

        ...;
    }
    

=cut

sub attr(@attrs){
    return $Template::Caribou::Attr{$_[0]} if @_ == 1;

    croak "number of attributes must be even" if @_ % 2;

    while( my ( $k, $v ) = splice @_, 0, 2 ) {
        if ( $k =~ s/^\+// ) {
            $Template::Caribou::Attr{$k} .= ' '. $v;
        }
        else {
            $Template::Caribou::Attr{$k} = $v;
        }
    }

    return;
}


sub _generate_mytag {
    my ( undef, undef, $arg ) = @_;

    $arg->{'-as'} ||= $arg->{tag}
        or die "mytag needs to be given '-as' or 'name'\n";

    my $tagname = $arg->{tag} || 'div';

    my $groom = sub {
        $_{class} ||= $arg->{class} if $arg->{class};

        $_{$_} ||= $arg->{attr}{$_} for eval { keys %{ $arg->{attr} } };

        $arg->{groom}->() if $arg->{groom};
    };

    return sub :prototype(&) {
        my $inner = shift;
        render_tag( $tagname, $inner, $groom, $arg->{indent}//1 );
    }
}

=function render_tag( $tag_name, $inner_block, \&groom )

Prints out a tag in a template. The C<$inner_block> is a string or coderef
holding the content of the tag. 

If the C<$inner_block> is empty, the tag will be of the form
C<< <foo /> >>.

    render_tag( 'div', 'hello' );         #  <div>hello</div>

    render_tag( 'div', sub { 'hello' } )  # <div>hello</div>

    render_tag( 'div', '' );              #  <div />

An optional grooming function can be passed. If it is, an hash holding the 
attributes of the tag, and its inner content will be passed to it as C<%_> and C<$_>, respectively.

   # '<div>the current time is Wed Nov 25 13:18:33 2015</div>'
   render_tag( 'div', 'the current time is DATETIME', sub {
        s/DATETIME/scalar localtime/eg;
   });

   # '<div class="mine">foo</div>'
   render_tag( 'div', 'foo', sub { $_{class} = 'mine' } )




=cut

sub render_tag {
    my ( $tag, $inner_sub, $groom, $indent ) = @_;

    $indent //= 1;

    local $Template::Caribou::TAG_INDENT_LEVEL = $indent ? $Template::Caribou::TAG_INDENT_LEVEL : 0;

    my $sub = ref $inner_sub eq 'CODE' ? $inner_sub : sub { $inner_sub };

    # need to use the object for calls to 'show'
    my $bou = $Template::Caribou::TEMPLATE || Moose::Meta::Class->create_anon_class(
        roles => [ 'Template::Caribou::Role' ] 
    )->new_object;

    local %Template::Caribou::Attr;

    my $inner = do {
        local $Template::Caribou::TAG_INDENT_LEVEL = $Template::Caribou::TAG_INDENT_LEVEL;

        $Template::Caribou::TAG_INDENT_LEVEL++
            if $Template::Caribou::TAG_INDENT_LEVEL // $bou->indent;

        $bou->get_render($sub);
    };

    my %attr = %Template::Caribou::Attr;

    if ( $groom ) {
        local $_ = "$inner";  # stringification required in case it's an object
        local %_ = %attr;

        $groom->();

        ($inner,%attr) = ( $_, %_ );
    }

    my $attrs;
    for( sort keys %attr ) {
        # TODO deal with the quotes
        $attrs .= qq{ $_="$attr{$_}"};
    }

    no warnings qw/ uninitialized /;

    my $prefix = !!$Template::Caribou::TAG_INDENT_LEVEL 
        && "\n" . ( '  ' x $Template::Caribou::TAG_INDENT_LEVEL );

    my $output = length($inner) 
        ? Template::Caribou::String->new( "$prefix<${tag}$attrs>$inner$prefix</$tag>" ) 
        : Template::Caribou::String->new( "$prefix<${tag}$attrs />" ) 
        ;

    return print_raw( $output );
}

sub print_raw($text) {
    print ::RAW $text;
    return $text; 
}

1;
