use strict;
use warnings;

package MyTemplate;

use Test::More tests => 5;

use Template::Caribou;
use Class::MOP::Class;

my $first  = MyTemplate->new;
my $second = MyTemplate->new;

ok ! $second->has_template('foo'), "not defined yet";

$first->set_template( 'foo' => sub { } );

ok $second->has_template('foo'), "class-wide";

my $third = MyTemplate->anon_instance;

ok $third->has_template('foo'), "inherited";

$third->set_template( 'bar' => sub { } );

ok $third->has_template('bar'), "third has it";
ok !$second->has_template('bar'), "but not the rest";



