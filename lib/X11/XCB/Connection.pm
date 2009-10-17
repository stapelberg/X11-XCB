package X11::XCB::Connection;
# passes all methods to the underlying XCBConnection.

use Moose;
use X11::XCB qw(:all);
use X11::XCB::Screen;
use X11::XCB::Window;
use List::Util qw(sum);

has 'display' => (is => 'rw', isa => 'Str');
has 'conn' => (is => 'rw', isa => 'XCBConnectionPtr', handles => qr/.*/);

sub BUILD {
    my $self = shift;

    # TODO: do we need this one?
    my $screens;
    my $conn = X11::XCB->new($self->display, $screens);

    $self->conn($conn);
}

sub atom {
    my $self = shift;

    return X11::XCB::Atom->new(_conn => $self->conn, @_);
}

sub color {
    my $self = shift;

    return X11::XCB::Color->new(_conn => $self->conn, @_);
}

sub root {
    my $self = shift;

    my $screens = $self->screens;
    my $width = sum map { $_->rect->width } @{$screens};
    my $height = sum map { $_->rect->height } @{$screens};

    return X11::XCB::Window->new(
        _conn => $self->conn,
        _mapped => 1, # root window is always mapped
        parent => 0,
        id => $self->conn->get_root_window(),
        rect => X11::XCB::Rect->new(x => 0, y => 0, width => $width, height => $height),
        class => WINDOW_CLASS_INPUT_OUTPUT, # FIXME: is this correct for the root win?
    );
}

sub input_focus {
    my $self = shift;

    my $conn = X11::XCB::Connection->conn;
    my $cookie = $conn->get_input_focus();
    my $reply = $conn->get_input_focus_reply($cookie->{sequence});

    return $reply->{focus};
}

=head2 screens

Returns an arrayref of L<X11::XCB::Screen>s.

=cut
sub screens {
    my $self = shift;

    my $conn = $self->conn;
    my $cookie = $conn->xinerama_query_screens;
    my $screens = $conn->xinerama_query_screens_reply($cookie->{sequence});
    my @result;
    for my $geom (@{$screens->{screen_info}}) {
        my $rect = X11::XCB::Rect->new(
                x => $geom->{x_org},
                y => $geom->{y_org},
                width => $geom->{width},
                height => $geom->{height}
        );
        push @result, X11::XCB::Screen->new(rect => $rect);
    }

    return \@result;
}

1
# vim:ts=4:sw=4:expandtab
