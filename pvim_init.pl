#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use Path::Class;
use Cwd;

my $dir = dir( getcwd );

my ( $project_name ) = $dir->dir_list( -1, 1 );

say "$project_name=$dir CD=. {";

lib_files($dir);
test_files($dir);
maint_files($dir);

say "}";

sub lib_files {
    my $dir = shift;
    $dir = $dir->subdir('lib');

    say "lib Files=lib {";

    $dir->recurse( callback => sub {
        my $entry = shift;
        return unless -f $entry and $entry =~ /\.pm$/;

        $entry = $entry->relative($dir);
        
        say "  $entry";

    } );

    say "}";

}

sub test_files {
    my $dir = shift;
    $dir = $dir->subdir('t');

    say "tests Files=t {";

    $dir->recurse( callback => sub {
        my $entry = shift;
        return unless -f $entry;

        $entry = $entry->relative($dir);
        
        say "  $entry";

    } );

    say "}";

}


sub maint_files {
    my $dir = shift;

    say "distro Files=. {";

    say "  $_" for map { $_->relative($dir) } grep { -f $_ } $dir->children;

    say "}";

}


