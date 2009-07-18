package X11::XCB::Window;

use Moose;
use Moose::Util::TypeConstraints;
use X11::XCB::Rect;
use X11::XCB::Connection;
use X11::XCB::Atom;
use X11::XCB qw(:all);
use Data::Dumper;

# A valid window type is every string, which, appended to _NET_WM_WINDOW_TYPE_
# returns an existing atom.
subtype 'ValidWindowType'
    => as 'Str'
    => where {
        my $c = X11::XCB::Atom->new(name => '_NET_WM_WINDOW_TYPE_' . uc($_));
        # Unfortunately, we cannot use TryCatch here. If anyone figures out
        # why, please send a patch :-)
        eval {
            $c->id;
        };
        # If there was an error, $@ is not undef. Thus, we return whether
        # there was no error
        return !$@;
    }
    => message { "The window type you provided ($_) does not exist" };

# We can make an Atom out of a valid window type
coerce 'X11::XCB::Atom'
    => from 'ValidWindowType'
    => via { X11::XCB::Atom->new(name => '_NET_WM_WINDOW_TYPE_' . uc($_)) };

has 'class' => (is => 'ro', isa => 'Str', required => 1);
has 'id' => (is => 'ro', isa => 'Int', init_arg => undef, lazy_build => 1);
has '_rect' => (is => 'ro', isa => 'X11::XCB::Rect', required => 1, init_arg => 'rect');
has 'type' => (is => 'rw', isa => 'X11::XCB::Atom', coerce => 1, trigger => \&_update_type);
has 'override_redirect' => (is => 'ro', isa => 'Int', default => 0);
# TODO: make this a string and convert it
has 'background_color' => (is => 'ro', isa => 'Int', default => undef);
has 'name' => (is => 'rw', isa => 'Str', trigger => \&_update_name);
has 'fullscreen' => (is => 'rw', isa => 'Int', trigger => \&_update_fullscreen);
has '_conn' => (is => 'ro', default => sub { X11::XCB::Connection->instance });
has '_mapped' => (is => 'rw', isa => 'Int', default => 0);
has '_created' => (is => 'rw', isa => 'Int', default => 0);

sub _build_id {
    my $self = shift;

    return $self->_conn->generate_id();
}

=head2 rect

As long as the window is not mapped, this returns the planned geometry. After
the window is mapped, every time you access C<rect>, the geometry will be
determined by querying X11 about it, thus generating at least 1 round-trip for
non-reparenting window managers and two or more round-trips for reparenting
window managers.

=cut
sub rect {
    my $self = shift;

    # Return the planned geometry if we’re not yet mapped
    return $self->_rect unless $self->_mapped;

    my $conn = $self->_conn;

    # Get the relative geometry
    my $cookie = $conn->get_geometry($self->id);
    my $relative_geometry = $conn->get_geometry_reply($cookie->{sequence});

    my $last_id = $self->id;

    while (1) {
        $cookie = $conn->query_tree($last_id);
        my $reply = $conn->query_tree_reply($cookie->{sequence});

        # If this is the root window, we stop here
        last if ($reply->{root} == $reply->{parent});

        $last_id = $reply->{parent};
    }

    # If this window is a direct child of the root window, the relative
    # geometry is equal to the absolute geometry
    return X11::XCB::Rect->new($relative_geometry) if ($last_id == $self->id);

    $cookie = $conn->get_geometry($last_id);
    my $absolute_geometry = $conn->get_geometry_reply($cookie->{sequence});

    return X11::XCB::Rect->new(
            x => $absolute_geometry->{x} + $relative_geometry->{x},
            y => $absolute_geometry->{y} + $relative_geometry->{y},
            width => $relative_geometry->{width},
            height => $relative_geometry->{height},
    );
}

sub create {
    my $self = shift;
    my $root_window = $self->_conn->get_root_window();
    my $mask = 0;
    my @values;

    if ($self->background_color) {
        $mask |= CW_BACK_PIXEL;
        push @values, $self->background_color;
    }


    if ($self->override_redirect == 1) {
        $mask |= CW_OVERRIDE_REDIRECT;
        push @values, 1;
    }

    $self->_conn->create_window(
            WINDOW_CLASS_COPY_FROM_PARENT,
            $self->id,
            $self->_conn->get_root_window(),
            $self->_rect->x,
            $self->_rect->y,
            $self->_rect->width,
            $self->_rect->height,
            0, # border
            $self->class,
            0, # copy visual TODO
            $mask,
            @values
    );

    $self->_created(1);

    $self->_update_type if (defined($self->type));
}

sub map {
    my $self = shift;

    $self->_conn->map_window($self->id);
    $self->_conn->flush;
    $self->_mapped(1);
}

sub _update_name {
    my $self = shift;
    my $atomname = X11::XCB::Atom->new(name => '_NET_WM_NAME');
    my $atomtype = X11::XCB::Atom->new(name => 'UTF8_STRING');
    my $strlen;

    # Disable UTF8 mode to get the raw amount of bytes in this string
    { use bytes; $strlen = length($self->name); }

    $self->_conn->change_property(
            PROP_MODE_REPLACE,
            $self->id,
            $atomname->id,
            $atomtype->id,
            8,      # 8 bit per entity
            $strlen,    # length(name) entities
            $self->name
    );
    $self->_conn->flush;
}

sub _update_fullscreen {
    my $self = shift;
    my $conn = $self->_conn;
    my $atomname = X11::XCB::Atom->new(name => '_NET_WM_STATE');

    # If we’re already mapped, we have to send a client message to the root
    # window containing our request to change the _NET_WM_STATE atom.
    #
    # (See EWMH → Application window properties)
    if ($self->_mapped) {
        my %event = (
                response_type => CLIENT_MESSAGE,
                format => 32,   # 32-bit values
                sequence => 0,  # filled in by xcb
                window => $self->id,
                type => $atomname->id,
        );

        my $packed = pack('CCSLL(LLLL)',
                $event{response_type},
                $event{format},
                $event{sequence},
                $event{window},
                $event{type},
                _NET_WM_STATE_TOGGLE,
                X11::XCB::Atom->new(name => '_NET_WM_STATE_FULLSCREEN')->id,
                0,
                1, # normal application
        );

        $conn->send_event(
                0, # don’t propagate (= send only to matching clients)
                $conn->get_root_window(),
                EVENT_MASK_SUBSTRUCTURE_REDIRECT,
                $packed
        );
    } else {
        my $atomtype = X11::XCB::Atom->new(name => 'ATOM');
        my $atom = X11::XCB::Atom->new(
                name => ($self->fullscreen ?
                            '_NET_WM_STATE_NORMAL' :
                            '_NET_WM_STATE_FULLSCREEN')
        );

        $conn->change_property(
                PROP_MODE_REPLACE,
                $self->id,
                $atomname->id,
                $atomtype->id,
                32,         # 32 bit integer
                1,
                pack('L', $atom->id)
        );
    }

    $conn->flush;
}

sub _update_type {
    my $self = shift;
    my $atomname = X11::XCB::Atom->new(name => '_NET_WM_WINDOW_TYPE');
    my $atomtype = X11::XCB::Atom->new(name => 'ATOM');

    # If we are not mapped, this property will be set when creating the window
    return unless ($self->_created);

    $self->_conn->change_property(
        PROP_MODE_REPLACE,
        $self->id,
        $atomname->id,
        $atomtype->id,
        32,         # 32 bit integer
        1,
        pack('L', $self->type->id)
    );
    $self->_conn->flush;
}

1
# vim:ts=4:sw=4:expandtab
