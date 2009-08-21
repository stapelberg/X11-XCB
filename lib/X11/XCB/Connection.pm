package X11::XCB::Connection;
# singleton, because you usually only need one connection to X
# passes all methods to the underlying XCBConnection.

use MooseX::Singleton;
use X11::XCB qw(:all);

has 'display' => (is => 'rw', isa => 'Str');
has 'conn' => (is => 'rw', isa => 'XCBConnectionPtr', handles => qr/.*/);

sub connect {
    my $class = shift;
    my $display = shift;

    # TODO: do we need this one?
    my $screens;
    my $conn = X11::XCB->new($display, $screens);

    X11::XCB::Connection->display($display);
    X11::XCB::Connection->conn($conn);
}

sub input_focus {
    my $class = shift;

    my $conn = X11::XCB::Connection->conn;
    my $cookie = $conn->get_input_focus();
    my $reply = $conn->get_input_focus_reply($cookie->{sequence});

    return $reply->{focus};
}

1
# vim:ts=4:sw=4:expandtab
