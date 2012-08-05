package Template::Caribou::Tags::HTML::Extended;
# ABSTRACT: custom HTML tags optimized for DWIMery

use strict;
use warnings;

use Carp;

use Template::Caribou::Tags ':all';

use Sub::Exporter -setup => {
    exports => [qw/ css anchor image markdown javascript js_include submit
    less /]
};

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

=head2 js_include $url

Shortcut for 

    <script type="text/javascript" src="http://..."> </script>

=cut

sub js_include($) {
    my $url = shift;

    render_tag( 'script', sub {
        attr type => 'text/javascript',
             src => $url;
             print ::RAW ' ';  # to prevent collapsing the tag
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

sub anchor($$) {
    my ( $href, $inner ) = @_;
    render_tag( 'a', $inner, sub {
        $_[0]->{href} ||= $href;
    });
}

=head2 image $src, @attr

Shortcut for <img>.

=cut

sub image(@) {
    my ( $src, %attr ) = @_;

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
