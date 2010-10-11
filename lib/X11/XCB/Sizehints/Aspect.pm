package X11::XCB::Sizehints::Aspect;

use Moose;
use Data::Dumper;
use v5.10;

has 'min_num' => (is => 'rw', isa => 'Int');
has 'min_den' => (is => 'rw', isa => 'Int');
has 'max_num' => (is => 'rw', isa => 'Int');
has 'max_den' => (is => 'rw', isa => 'Int');

1
