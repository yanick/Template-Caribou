package Template::Caribou::Tags::HTML;
# ABSTRACT: Basic HTML tag library

=head1 SYNOPSIS

    package MyTemplate;

    use Template::Caribou;

    use Template::Caribou::Tags::HTML;

    template main => sub {
        html {
            head { title { "Website X" } };
            body {
                h1 { "Some Title" };
                div {
                    "Blah blah";
                };
            };
        };
    };

=head1 DESCRIPTION

Exports tag blocks for regular HTML tags. 

=head1 TAG FUNCTIONS EXPORTED

p html head h1 h2 h3 h4 h5 h6 body emphasis div sup style title span li ol ul i b bold a label link img section article table thead tbody th td table_row fieldset legend form input select option button small textarea 

All function names are the same than their tag name, except for C<table_row>, which is for C<tr> (which is an already taken Perl keyword).

=cut

use strict;
use warnings;

use parent 'Exporter::Tiny';

our @EXPORT;

BEGIN {
    @EXPORT = @Template::Caribou::Tags::HTML::TAGS =  qw/
        p html head h1 h2 h3 h4 h5 h6 body emphasis div
        sup
        style title span li ol ul i b bold a 
        label link img section article
        table thead tbody th td
        fieldset legend form input select option button
        small
        textarea
    /;
    push @EXPORT, 'table_row';
}

use Template::Caribou::Tags
    mytag => { -as => 'table_row', tag => 'tr' },
    map { ( mytag => { -as => $_, tag => $_ } ) }
        @Template::Caribou::Tags::HTML::TAGS;

1;
