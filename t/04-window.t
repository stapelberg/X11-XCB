#!perl

use Test::More tests => 4;
use Test::Deep;
use X11::XCB qw(:all);
use Data::Dumper;

BEGIN {
	use_ok('X11::XCB::Connection') or BAIL_OUT('Unable to load X11::XCB::Connection');
	use_ok('X11::XCB::Window');
}

my $x = X11::XCB::Connection->new(display => ':0');

my $original_rect = X11::XCB::Rect->new(x => 0, y => 0, width => 30, height => 30);

my $root = $x->root;

isa_ok($root, 'X11::XCB::Window');

my $rect = $root->rect;

ok('rect of the root window could be retrieved');

my $window = $x->root->create_child(
	class => WINDOW_CLASS_INPUT_OUTPUT,
	rect => $original_rect,
	background_color => '#C0C0C0',
);

$window->create;
$window->map;
sleep 1;

diag( "Testing X11::XCB, Perl $], $^X" );
