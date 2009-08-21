package X11::XCB::Rect;

use Moose;
use Moose::Util::TypeConstraints;

coerce 'X11::XCB::Rect'
    => from 'ArrayRef'
    => via { X11::XCB::Rect->new(x => $_->[0], y => $_->[1], width => $_->[2], height => $_->[3]); };

has [ qw(x y width height) ] => (is => 'ro', isa => 'Int', required => 1);

1
# vim:ts=4:sw=4:expandtab
