package X11::XCB::Atom;

use Moose;
use X11::XCB::Connection;

has 'name' => (is => 'ro', isa => 'Str', required => 1, trigger => \&_request);
has 'id' => (is => 'ro', isa => 'Int', lazy_build => 1);
has '_sequence' => (is => 'rw', isa => 'Int');
has '_conn' => (is => 'ro', default => sub { X11::XCB::Connection->instance });

sub _build_id {
	my $self = shift;

	return $self->_conn->intern_atom_reply($self->_sequence)->{atom};
}

sub _request {
	my $self = shift;

	# Place the request directly after the name is set, we get the response later
	my $request = $self->_conn->intern_atom(0, length($self->name), $self->name);

	# Save the sequence to identify the response
	$self->_sequence($request->{sequence});
}

1
