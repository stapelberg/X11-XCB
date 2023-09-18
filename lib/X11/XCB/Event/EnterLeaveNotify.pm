package X11::XCB::Event::EnterLeaveNotify;

use Mouse;

# XXX: the following are filled in by XS
has [ 'response_type', 'sequence', 'detail', 'time', 'root', 'event', 'child', 'root_x', 'root_y', 'event_x', 'event_y', 'state', 'mode', 'same_screen_focus' ] => (is => 'ro', isa => 'Int');

__PACKAGE__->meta->make_immutable;

1
# vim:ts=4:sw=4:expandtab
