package X11::XCB::Window;

use Moose;
use X11::XCB::Rect;
use X11::XCB::Connection;
use X11::XCB qw(:all);
use Data::Dumper;

has 'class' => (is => 'ro', isa => 'Str', required => 1);
has 'id' => (is => 'ro', isa => 'Int', init_arg => undef, lazy_build => 1);
has '_rect' => (is => 'ro', isa => 'X11::XCB::Rect', required => 1, init_arg => 'rect');
has 'override_redirect' => (is => 'ro', isa => 'Int', default => 0);
# TODO: make this a string and convert it
has 'background_color' => (is => 'ro', isa => 'Int', default => undef);
has 'name' => (is => 'rw', isa => 'Str', trigger => \&_update_name);
has 'fullscreen' => (is => 'rw', isa => 'Int', trigger => \&_update_fullscreen);
has '_conn' => (is => 'ro', default => sub { X11::XCB::Connection->instance });
has '_mapped' => (is => 'rw', isa => 'Int', default => 0);

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

	my $last_window_id = $self->id;

	while (1) {
		$cookie = $conn->query_tree($last_window_id);
		my $reply = $conn->query_tree_reply($cookie->{sequence});

		# If this is the root window, we stop here
		last if ($reply->{root} == $reply->{parent});

		$last_window_id = $reply->{parent};
	}

	# If this window is a direct child of the root window, the relative
	# geometry is equal to the absolute geometry
	return $relative_geometry if ($last_window_id == $self->id);

	$cookie = $conn->get_geometry($last_window_id);
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
			8, 		# 8 bit per entity
			$strlen, 	# length(name) entities
			$self->name
	);
	$self->_conn->flush;
}

sub _update_fullscreen {
	my $self = shift;
	my $atomname = X11::XCB::Atom->new(name => '_NET_WM_STATE');
	my $atomtype = X11::XCB::Atom->new(name => 'ATOM');
	my $atom;
	if ($self->fullscreen) {
		$atom = X11::XCB::Atom->new(name => '_NET_WM_STATE_FULLSCREEN');
	} else {
		$atom = X11::XCB::Atom->new(name => '_NET_WM_STATE_NORMAL');
	}

	$self->_conn->change_property(
			PROP_MODE_REPLACE,
			$self->id,
			$atomname->id,
			$atomtype->id,
			32, 		# 32 bit integer
			1,
			pack('I', $atom->id)
	);
	$self->_conn->flush;
}


1
