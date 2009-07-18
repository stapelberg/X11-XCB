package X11::XCB::Atom;

use Moose;
use X11::XCB::Connection;
use Carp;
use TryCatch;

has 'name' => (is => 'ro', isa => 'Str', required => 1, trigger => \&_request);
has 'id' => (is => 'ro', isa => 'Int', lazy_build => 1);
has '_sequence' => (is => 'rw', isa => 'Int');
has '_conn' => (is => 'ro', default => sub { X11::XCB::Connection->instance });
has '_id' => (is => 'rw', isa => 'Int', default => undef);

sub _build_id {
    my $self = shift;
    my $id;

    # If we have already gotten our reply, we use it again
    if (defined($self->_id)) {
        $id = $self->_id;
    } else {
        $id = $self->_conn->intern_atom_reply($self->_sequence)->{atom};
        $self->_id($id);
    }

    # None = 0 means the atom does not exist
    croak "No such atom" if ($id == 0);

    return $id;
}

sub _request {
    my $self = shift;

    # Place the request directly after the name is set, we get the reply later
    my $request = $self->_conn->intern_atom(
        1, # do not create the atom if it does not exist
        length($self->name),
        $self->name
    );

    # Save the sequence to identify the response
    $self->_sequence($request->{sequence});
}

=head2 exists

Returns whether this atom actually exists. If the id of the atom has not been
requested before, this generates a round-trip to the x server. This is very
likely, as id() dies if the atom does not exist.

=cut
sub exists {
    my $self = shift;

    try {
        # Try to access the ID. If this fails, the provided name was invalid
        $self->id;
        return 1;
    }
    catch {
    }
}

1
# vim:ts=4:sw=4:expandtab
