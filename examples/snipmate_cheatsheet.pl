#!/usr/bin/env perl 

use SnipMate::Snippets;

say SnipMate::Snippets->new( snippet_file => shift )->render('webpage');
