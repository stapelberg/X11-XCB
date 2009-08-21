#!perl

use Test::More tests => 6;
use Test::Deep;
use X11::XCB qw(:all);
use List::Util qw(first);

BEGIN {
	use_ok('X11::XCB::Connection') or BAIL_OUT('Unable to load X11::XCB::Connection');
	use_ok('X11::XCB::Screen');
}

X11::XCB::Connection->connect(':0');

my $conn = X11::XCB::Connection->instance;
my $screens = $conn->screens;
my $first = first { 1 } @{$screens};
isa_ok($first, 'X11::XCB::Screen');

my $primary = first { $_->primary } @{$screens};
isa_ok($primary, 'X11::XCB::Screen');
is($primary->rect->x, 0, 'primary screens x == 0');
is($primary->rect->y, 0, 'primary screens y == 0');

diag( "Testing X11::XCB, Perl $], $^X" );
