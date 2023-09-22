package X11::XCB::Event::MapRequest;

use Mouse;

# XXX: the following are filled in by XS
has [ 'response_type', 'sequence', 'window', 'parent' ] => (is => 'ro', isa => 'Int');

__PACKAGE__->meta->make_immutable;

1
# vim:ts=4:sw=4:expandtab
