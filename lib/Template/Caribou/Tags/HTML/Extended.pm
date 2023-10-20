package Template::Caribou::Tags::HTML::Extended;
# ABSTRACT: custom HTML tags optimized for DWIMery


use strict;
use warnings;

use Carp;

use Template::Caribou::Tags qw/ render_tag attr /;
use Class::Load qw/ load_class /;

use experimental 'signatures';

use parent 'Exporter::Tiny';

our @EXPORT = qw/
    css anchor image markdown javascript javascript_include submit
    less css_include doctype
    favicon

/;

=head2 doctype $type

    doctype 'html5';
    # <!DOCTYPE html>

Prints the doctype declaration for the given type. 

For the moment, only I<html 5> (or I<html5>) is supported as a type.

=cut

sub doctype($type="html 5") {
    if ( $type =~ /^html\s?5/ ) {
        return Template::Caribou::Tags::print_raw( "<!DOCTYPE html>\n" );
    }

    croak "type '$type' not supported";
}

=head2 favicon $url

Generates a favicon link tag.

    favicon 'my_icon.png';
    # <link rel="shortcut icon" href="my_icon.png" />

=cut

sub favicon($url) {
    render_tag( 'link', sub {
            attr rel => 'shortcut icon',
            href => $url
    } );
}

=head2 submit $value, %attr

    submit 'foo';
    # <input type="submit" value="foo" />

Shortcut for

    input { attr type => submit, value => $value, %attr; }

=cut

sub submit($value=undef, %attr) {

    render_tag( 'input', '', sub {
        $_{type} = 'submit';
        $_{value} = $value if $value;
        $_{$_} = $attr{$_} for keys %attr;
    });
}

=head2 less $script

Compiles the LESS script into CSS. Requires L<CSS::LESSp>.

=cut

sub less($text) {
    my $css = join '', load_class('CSS::LESSp')->parse($text);

    css($css);
}


=head2 javascript $script

    javascript q{ console.log( "Hello there!" ) };
    # <script type="text/javascript">console.log( "Hello there!" )</script>

Shortcut for 

    <script type="text/javascript>$script</script>

=cut

sub javascript($script) {
    render_tag( 'script', sub {
        attr type => 'text/javascript';
        print ::RAW $script;
    });
}

=head2 javascript_include $url

Shortcut for 

    <script type="text/javascript" src="http://..."> </script>

=cut

sub javascript_include($url) {
    render_tag( 'script', sub {
        attr type => 'text/javascript',
             src => $url;
             print ::RAW ' ';  # to prevent collapsing the tag
    });
}

=head2 css_include $url, %args

    css_include 'public/bootstrap/css/bootstrap.min.css', media => 'screen';
    # <link href="public/bootstrap/css/bootstrap.min.css" rel="stylesheet"
    #       media="screen" />

=cut

sub css_include( $url, %args ) {
    render_tag( 'link', sub {
        attr rel => 'stylesheet',
             href => $url,
             %args
             ;
    });
}

=head2 css $text

Wraps the I<$text> in a style element.

    <style type="text/css">$text</style>

=cut

sub css($css) {
    render_tag( 'style', sub {
        attr type => 'text/css';
        $css;
    });
};

=head2 anchor $url, $inner

Shortcut for <a>. I<$inner> can be either a string, or a subref.

    anchor 'http://foo.com' => 'linkie';

is equivalent to 

    a {
        attr href => 'http://foo.com';
        'linkie';
    }

=cut

sub anchor($href,$inner) {
    render_tag( 'a', $inner, sub {
        $_{href} ||= $href;
    });
}

=head2 image $src, %attr

    image 'kitten.jpg';
    # <img src="kitten.jpg" />

Shortcut for <img>.

=cut

sub image($src,%attr) {

    croak "src required" unless $src;

    $attr{src} = $src;

    render_tag( 'img', '', sub {
        $_{$_} = $attr{$_} for keys %attr;
    } );
}

=head2 markdown $text

Converts the markdown $text into its html equivalent.

Uses L<Text::MultiMarkdown>.

=cut

sub markdown($md){
    require Text::MultiMarkdown;

    return unless length $md;

    my $value = Text::MultiMarkdown::markdown($md);

    print ::RAW $value;
}

1;

__END__

=head1 SYNOPSIS

    package MyTemplate;

    use Moose;

    use Template::Caribou::Tags::HTML;
    use Template::Caribou::Tags::HTML::Extended;

    with 'Template::Caribou';

    template 'page' => sub {
        html {
            head { 
                css q{
                    color: magenta;
                };
            };
            body {
                markdown q{Ain't Markdown **grand**?};
                
                anchor "http://foo.com" => sub {
                    image 'http://foo.com/bar.jpg', alt => 'Foo logo';
                };
            }

        }
    };

=head1 DESCRIPTION

Whereas L<Template::Caribou::Tags::HTML> offers straight function equivalents to their
HTML tags, this module provides a more DWIM interface, and shortcut for often used patterns.
