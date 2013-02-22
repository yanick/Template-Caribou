package Template::Caribou::Tags::HTML::Extended;
BEGIN {
  $Template::Caribou::Tags::HTML::Extended::AUTHORITY = 'cpan:YANICK';
}
{
  $Template::Caribou::Tags::HTML::Extended::VERSION = '0.2.0';
}
# ABSTRACT: custom HTML tags optimized for DWIMery

use strict;
use warnings;

use Carp;

use Method::Signatures;

use Template::Caribou::Tags ':all';

use Sub::Exporter -setup => {
    exports => [qw/ css anchor image markdown javascript javascript_include submit
    less css_include doctype
    favicon
    /],
    groups => { default => ':all' },
};


sub doctype($) {
    my $type = shift;

    if ( $type eq 'html 5' ) {
        print ::RAW "<!DOCTYPE html>\n";
        return;
    }

    die "type '$type' not supported";
}


sub favicon($) {
    my $url = shift;

    render_tag( 'link', sub {
            attr rel => 'shortcut icon',
            href => $url
    } );
}


sub submit(@) {
    my( $value, %attr ) = @_;

    render_tag( 'input', '', sub {
        $_[0]->{type} = 'submit';
        $_[0]->{value} = $value if $value;
        $_[0]->{$_} = $attr{$_} for keys %attr;
    });
}


sub less($) {
    my $text = shift;

    require CSS::LESSp;

    my $css = join '', CSS::LESSp->parse($text);

    css($css);
}



sub javascript($) {
    my $script = shift;
    render_tag( 'script', sub {
        attr type => 'text/javascript';
        print ::RAW $script;
    });
}


sub javascript_include($) {
    my $url = shift;

    render_tag( 'script', sub {
        attr type => 'text/javascript',
             src => $url;
             print ::RAW ' ';  # to prevent collapsing the tag
    });
}


func css_include( $url, \%args? = () ) {
    render_tag( 'link', sub {
        attr rel => 'stylesheet',
             href => $url,
             %args
             ;
    });
}


sub css($) {
    my $css = shift;
    render_tag( 'style', sub {
        attr type => 'text/css';
        $css;
    });
};


sub anchor($$) {
    my ( $href, $inner ) = @_;
    render_tag( 'a', $inner, sub {
        $_[0]->{href} ||= $href;
    });
}


sub image(@) {
    my ( $src, %attr ) = @_;

    croak "src required" unless $src;

    $attr{src} = $src;

    render_tag( 'img', '', sub {
        $_[0]->{$_} = $attr{$_} for keys %attr;
    } );
}


sub markdown($){
    require Text::MultiMarkdown;

    return unless length $_[0];

    print ::RAW Text::MultiMarkdown::markdown(shift);
}

1;

__END__

=pod

=head1 NAME

Template::Caribou::Tags::HTML::Extended - custom HTML tags optimized for DWIMery

=head1 VERSION

version 0.2.0

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

=head2 doctype $type

Prints the doctype declaration for the given type. 

For the moment, only I<html 5> is supported as a type.

=head2 favicon $url

Generates the favicon tag.

    favicon 'my_icon.png';

will generates

    <link rel="shortcut icon" href="my_icon.png" />

=head2 submit $value, %attr

Shortcut for

    input { attr type => submit, value => 'value', %attr; }

If you don't want I<value> to be passed, the first argument might be
set to I<undef>.

=head2 less $script

Compile the LESS script into CSS.

=head2 javascript $script

Shortcut for 

    <script type="text/javascript>$script</script>

=head2 javascript_include $url

Shortcut for 

    <script type="text/javascript" src="http://..."> </script>

=head2 css_include
<link href="public/bootstrap/css/bootstrap.min.css" rel="stylesheet"
        media="screen" />

=head2 css $text

Wraps the I<$text> in a style element.

    <style type="text/css">$text</style>

=head2 anchor $url, $inner

Shortcut for <a>. I<$inner> can be either a string, or a subref.

    anchor 'http://foo.com' => 'linkie';

is equivalent to 

    a {
        attr href => 'http://foo.com';
        'linkie';
    }

=head2 image $src, @attr

Shortcut for <img>.

=head2 markdown $text

Converts the markdown $text into its html equivalent.

Uses L<Text::MultiMarkdown>.

=head1 AUTHOR

Yanick Champoux

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
