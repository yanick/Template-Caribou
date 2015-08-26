package Template::Caribou::Tags::HTML::Extended;
# ABSTRACT: custom HTML tags optimized for DWIMery

use strict;
use warnings;

use Carp;

use Template::Caribou::Tags ':all';

use experimental 'signatures';

use Sub::Exporter -setup => {
    exports => [qw/ css anchor image markdown javascript javascript_include submit
    less css_include doctype
    favicon
    /],
    groups => { default => ':all' },
};

=head2 doctype $type

Prints the doctype declaration for the given type. 

For the moment, only I<html 5> is supported as a type.

=cut

sub doctype($) {
    my $type = shift;

    if ( $type eq 'html 5' ) {
        print ::RAW "<!DOCTYPE html>\n";
        return;
    }

    die "type '$type' not supported";
}

=head2 favicon $url

Generates the favicon tag.

    favicon 'my_icon.png';

will generates

    <link rel="shortcut icon" href="my_icon.png" />

=cut

sub favicon($) {
    my $url = shift;

    render_tag( 'link', sub {
            attr rel => 'shortcut icon',
            href => $url
    } );
}

=head2 submit $value, %attr

Shortcut for

    input { attr type => submit, value => 'value', %attr; }

If you don't want I<value> to be passed, the first argument might be
set to I<undef>.

=cut

sub submit(@) {
    my( $value, %attr ) = @_;

    render_tag( 'input', '', sub {
        $_[0]->{type} = 'submit';
        $_[0]->{value} = $value if $value;
        $_[0]->{$_} = $attr{$_} for keys %attr;
    });
}

=head2 less $script

Compile the LESS script into CSS.

=cut

sub less($) {
    my $text = shift;

    require CSS::LESSp;

    my $css = join '', CSS::LESSp->parse($text);

    css($css);
}


=head2 javascript $script

Shortcut for 

    <script type="text/javascript>$script</script>

=cut

sub javascript($) {
    my $script = shift;
    render_tag( 'script', sub {
        attr type => 'text/javascript';
        print ::RAW $script;
    });
}

=head2 javascript_include $url

Shortcut for 

    <script type="text/javascript" src="http://..."> </script>

=cut

sub javascript_include($) {
    my $url = shift;

    render_tag( 'script', sub {
        attr type => 'text/javascript',
             src => $url;
             print ::RAW ' ';  # to prevent collapsing the tag
    });
}

=head2 css_include
<link href="public/bootstrap/css/bootstrap.min.css" rel="stylesheet"
        media="screen" />

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

sub css($) {
    my $css = shift;
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
        $_[0]->{href} ||= $href;
    });
}

=head2 image $src, @attr

Shortcut for <img>.

=cut

sub image($src,%attr) {

    croak "src required" unless $src;

    $attr{src} = $src;

    render_tag( 'img', '', sub {
        $_[0]->{$_} = $attr{$_} for keys %attr;
    } );
}

=head2 markdown $text

Converts the markdown $text into its html equivalent.

Uses L<Text::MultiMarkdown>.

=cut

sub markdown($){
    require Text::MultiMarkdown;

    return unless length $_[0];

    print ::RAW Text::MultiMarkdown::markdown(shift);
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

I<Template::Caribou::Tags::HTML::Extended> provides utility tags that provides 
shortcuts for typical HTML constructs.
