package X11::XCB::Window;

use Moose;
use Moose::Util::TypeConstraints;
use X11::XCB::Rect;
use X11::XCB::Connection;
use X11::XCB::Atom;
use X11::XCB::Color;
use X11::XCB qw(:all);
use Data::Dumper;

# A valid window type is every string, which, appended to _NET_WM_WINDOW_TYPE_
# returns an existing atom.
subtype 'ValidWindowType'
    => as 'Str'
    => where {
        X11::XCB::Atom->new(name => '_NET_WM_WINDOW_TYPE_' . uc($_))->exists;
    }
    => message { "The window type you provided ($_) does not exist" };

# We can make an Atom out of a valid window type
coerce 'X11::XCB::Atom'
    => from 'ValidWindowType'
    => via { X11::XCB::Atom->new(name => '_NET_WM_WINDOW_TYPE_' . uc($_)) };

has 'class' => (is => 'ro', isa => 'Str', required => 1);
has 'id' => (is => 'ro', isa => 'Int', lazy_build => 1);
has 'parent' => (is => 'ro', isa => 'Int', required => 1);
has '_rect' => (is => 'ro', isa => 'X11::XCB::Rect', required => 1, init_arg => 'rect', coerce => 1);
has 'type' => (is => 'rw', isa => 'X11::XCB::Atom', coerce => 1, trigger => \&_update_type);
has 'override_redirect' => (is => 'ro', isa => 'Int', default => 0);
has 'background_color' => (is => 'ro', isa => 'X11::XCB::Color', coerce => 1, default => undef);
has 'name' => (is => 'rw', isa => 'Str', trigger => \&_update_name);
has 'fullscreen' => (is => 'rw', isa => 'Int', trigger => \&_update_fullscreen);
has '_conn' => (is => 'ro', required => 1);
has '_mapped' => (is => 'rw', isa => 'Int', default => 0);
has '_created' => (is => 'rw', isa => 'Int', default => 0);

sub _build_id {
    my $self = shift;

    return $self->_conn->generate_id();
}

=head2 rect

As long as the window is not mapped, this returns the planned geometry. As soon
as the window is mapped, this retuns its geometry B<including> the window
decorations.

Thus, after the window is mapped, every time you access C<rect>, the geometry
will be determined by querying X11 about it, thus generating at least 1 round-
trip for non-reparenting window managers and two or more round-trips for
reparenting window managers.

In scalar context it returns only the window’s geometry, in list context it
returns the window’s geometry and the geometry of the top window (the one
containing this window but the first one under the root window in hierarchy).
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
        last if ($reply->{root} == $reply->{parent}) or $reply->{parent} == 0;

        $last_id = $reply->{parent};
    }

    # If this window is a direct child of the root window, the relative
    # geometry is equal to the absolute geometry
    return X11::XCB::Rect->new($relative_geometry) if ($last_id == $self->id);

    $cookie = $conn->get_geometry($last_id);
    my $parent_geometry = $conn->get_geometry_reply($cookie->{sequence});

    my $absolute = X11::XCB::Rect->new(
            x => $parent_geometry->{x} + $relative_geometry->{x},
            y => $parent_geometry->{y} + $relative_geometry->{y},
            width => $relative_geometry->{width},
            height => $relative_geometry->{height},
    );

    return wantarray ? ($absolute, X11::XCB::Rect->new($parent_geometry)) : $absolute;
}

sub _create {
    my $self = shift;
    my $mask = 0;
    my @values;

    if ($self->background_color) {
        $mask |= CW_BACK_PIXEL;
        push @values, $self->background_color->pixel;
    }


    if ($self->override_redirect == 1) {
        $mask |= CW_OVERRIDE_REDIRECT;
        push @values, 1;
    }

    $self->_conn->create_window(
            WINDOW_CLASS_COPY_FROM_PARENT,
            $self->id,
            $self->parent,
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

=head2 attributes

Returns the X11 attributes of this window.

=cut
sub attributes {
    my $self = shift;
    my $conn = $self->_conn;

    my $cookie = $conn->get_window_attributes($self->id);
    my $attributes = $conn->get_window_attributes_reply($cookie->{sequence});

    return $attributes;
}

=head2 map

Maps the window on the screen, that is, makes it visible.

=cut
sub map {
    my $self = shift;

    $self->_create unless ($self->_created);

    $self->_conn->map_window($self->id);
    $self->_conn->flush;
    $self->_mapped(1);
}

=head2 unmap

The opposite of L<map>, that is, makes your window invisible.

=cut
sub unmap {
    my $self = shift;

    $self->_conn->unmap_window($self->id);
    $self->_conn->flush;
    $self->_mapped(1);
}

=head2 mapped

Returns whether the window is actually mapped (no internal state, but gets
the window attributes from X11 and checks for MAP_STATE_VIEWABLE).

=cut
sub mapped {
    my $self = shift;

    my $attributes = $self->attributes;

    # MAP_STATE_UNVIEWABLE is used when the window itself is mapped but one
    # of its ancestors is not
    return ($attributes->{map_state} == MAP_STATE_VIEWABLE);
}

sub _update_name {
    my $self = shift;
    my $conn = $self->_conn;
    my $atomname = $conn->atom(name => '_NET_WM_NAME');
    my $atomtype = $conn->atom(name => 'UTF8_STRING');
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
    my $atomname = $conn->atom(name => '_NET_WM_STATE');

    $self->_create unless ($self->_created);

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
                $conn->atom(name => '_NET_WM_STATE_FULLSCREEN')->id,
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
        my $atomtype = $conn->atom(name => 'ATOM');
        my $atoms;
        if ($self->fullscreen) {
            print "getting fs atom\n";
            my $atom = $conn->atom(name => '_NET_WM_STATE_FULLSCREEN');
            $atoms = pack('L', $atom->id);
        }

        $conn->change_property(
                PROP_MODE_REPLACE,
                $self->id,
                $atomname->id,
                $atomtype->id,
                32,         # 32 bit integer
                1,
                $atoms,
        );
    }

    $conn->flush;
}

sub _update_type {
    my $self = shift;
    my $conn = $self->_conn;
    my $atomname = $conn->atom(name => '_NET_WM_WINDOW_TYPE');
    my $atomtype = $conn->atom(name => 'ATOM');

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

=head2 create_child(options)

Creates a new C<X11::XCB::Window> as a child window of the current window.

=cut
sub create_child {
    my $self = shift;

    return X11::XCB::Window->new(
        _conn => $self->_conn,
        parent => $self->id,
        @_,
    );
}

1
# vim:ts=4:sw=4:expandtab
