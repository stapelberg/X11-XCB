package X11::XCB::Rect;

use Moose;

has [ qw(x y width height) ] => (is => 'ro', isa => 'Int', required => 1);

1
