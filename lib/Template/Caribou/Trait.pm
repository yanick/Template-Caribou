package Template::Caribou::Trait;

use Moose::Role;

use experimental 'signatures';

sub set_template($self,$name,$coderef) {
    $self->add_method( "template $name" => $coderef );
}

1;
