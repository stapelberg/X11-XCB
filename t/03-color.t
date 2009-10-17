#!perl

use Test::More tests => 4;
use Test::Deep;
use X11::XCB qw(:all);
use Data::Dumper;

BEGIN {
	use_ok('X11::XCB::Connection') or BAIL_OUT('Unable to load X11::XCB::Connection');
	use_ok('X11::XCB::Color');
}

my $x = X11::XCB::Connection->new(display => ':0');

my $color = $x->color(hexcode => 'C0C0C0');
is($color->pixel, 12632256, 'grey colorpixel matches');

$color = $x->color(hexcode => '#C0C0C0');
is($color->pixel, 12632256, 'grey colorpixel matches with #');

diag( "Testing X11::XCB, Perl $], $^X" );
