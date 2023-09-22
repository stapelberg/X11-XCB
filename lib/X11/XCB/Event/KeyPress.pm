package X11::XCB::Event::KeyPress;

use Mouse;

# XXX: the following are filled in by XS
has [ 'detail', 'time', 'root', 'event', 'child', 'root_x', 'root_y', 'event_x', 'event_y', 'state', 'same_screen' ] => (is => 'ro', isa => 'Int');

__PACKAGE__->meta->make_immutable;

1
# vim:ts=4:sw=4:expandtab
