#!/usr/bin/perl 

use strict;

sub p(&) {
    my $inner = do {
        local *STDOUT;
        local *RAW;
        local $Template::Caribou::OUTPUT;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *RAW, 'Template::Caribou::OutputRaw';
        my $res = $_[0]->();

        $Template::Caribou::OUTPUT 
            || ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    my $output = Template::Caribou::String->new( "<p>$inner</p>" );
    print $output unless defined wantarray;
    return $output;
}

sub render_tag {
    my ( $tag, $groom, $inner_sub ) = @_;

    my $inner;
    my %attr;

    {
        local *STDOUT;
        local *RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *RAW, 'Template::Caribou::OutputRaw';
        my $res = $inner_sub->();

        $inner = $Template::Caribou::OUTPUT 
            || ref $res ? $res : Template::Caribou::Output::escape( $res );

        %attr = %Template::Caribou::attr;
    };

    $groom->( \%attr, \$inner ) if $groom;

    my $attrs;
    while( my ( $tag, $value ) = each %attr ) {
        # TODO deal with the quotes
        $attrs .= qq{ $tag="$value"};
    }

    my $output = Template::Caribou::String->new( "<${tag}$attrs>$inner</$tag>" );
    print $output unless defined wantarray;
    return $output;
}

sub make_tag {
    my $tag = shift;

    my $def = <<'END_SUB';
sub __TAG__(&) {
    my $inner;
    my %attr;

    {
        local *STDOUT;
        local *RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *RAW, 'Template::Caribou::OutputRaw';
        my $res = $_[0]->();

        $inner = $Template::Caribou::OUTPUT 
            || ref $res ? $res : Template::Caribou::Output::escape( $res );

        %attr = %Template::Caribou::attr;
    };

    my $attrs;
    while( my ( $tag, $value ) = each %attr ) {
        # TODO deal with the quotes
        $attrs .= qq{ $tag="$value"};
    }

    my $output = Template::Caribou::String->new( "<__TAG__$attrs>$inner</__TAG__>" );
    print $output unless defined wantarray;
    return $output;
}
END_SUB

    $def =~ s/__TAG__/$tag/g;

    eval $def;

    die $@ if $@;

}

sub attr(@){
    my %attr = @_;
    $Template::Caribou::attr{$_} = $attr{$_} for keys %attr;
    return;
}

#BEGIN { make_tag( 'foo' ) ; }
#BEGIN { make_tag( 'bar' ) ; }

sub p(&) { render_tag( 'p', undef, shift ) }
sub my_img(&) { render_tag( 'p', sub { die "need a src" unless $_[0]->{src} }, shift ) }
 

p { 'ggg' };
my_img { attr src => '/blah', title => 'stuff' };


package Template::Caribou::String;

use overload 
    '""' => sub { return ${$_[0] } };

sub new { my ( $class, $string ) = @_;  bless \$string, $class; }


package Template::Caribou::Output;
use Tie::Handle;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub PRINT { print RAW escape( @_ ) } 

sub escape {
    @_ = map { 
        my $x = $_;
        $x =~ s/&/&amp;/g;
        $x =~ s/</<&lt;/;
        $x;
    } @_;

    return wantarray ? @_ : join '', @_;
}

package Template::Caribou::OutputRaw;
use Tie::Handle;

use parent 'Tie::Handle';

sub TIEHANDLE { return bless \my $i, shift; }

sub PRINT { $Template::Caribou::OUTPUT .= $_ for @_ } 
