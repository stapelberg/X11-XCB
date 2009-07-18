#!perl

use Test::More tests => 9;
use Test::Deep;
use X11::XCB qw(:all);
use Data::Dumper;
use TryCatch;

BEGIN {
	use_ok('X11::XCB::Atom') or BAIL_OUT('Unable to load X11::XCB::Atom');
}

X11::XCB::Connection->connect(':0');

my $atom = X11::XCB::Atom->new(name => '_NET_WM_STATE');

isa_ok($atom, 'X11::XCB::Atom');

is(int($atom->id), $atom->id, 'reply is an integer');

my $invalid = X11::XCB::Atom->new(name => 'this_atom_does_not_exist');

# We should be able to create the object
isa_ok($invalid, 'X11::XCB::Atom');

# This should crash
try {
	diag("id is = " . $invalid->id);
	fail('Invalid atom returned an ID');
}
catch {
	ok('Invalid atom die()d');
}

ok(!$invalid->exists, 'Invalid atom does not exist');

ok($atom->exists, 'Valid atom exists');

my $other_invalid = X11::XCB::Atom->new(name => 'this_atom_does_not_exist_too');

# We should be able to create the object
isa_ok($other_invalid, 'X11::XCB::Atom');

ok(!$other_invalid->exists, 'Fresh invalid atom does not exist');

diag( "Testing X11::XCB, Perl $], $^X" );
