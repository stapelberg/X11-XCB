# author needs Module::Install::{AuthorRequires,XSUtil}
use strict; use warnings;
use inc::Module::Install;
use lib '.';
use _GenerateMyXS;

name 'X11-XCB';
all_from 'lib/X11/XCB.pm.in';

configure_requires (my $PC = 'ExtUtils::PkgConfig');
require ExtUtils::PkgConfig;

$PC->atleast_version('xcb', '1.2')
    or die "You need at least libxcb version 1.2\n";

my @xcb_libs = qw(xcb xcb-xinerama xcb-icccm xcb-util);
eval { $PC->find($_) for @xcb_libs; 1 }
    or die << '__';
Please make sure you installed the development versions of
libxcb, libxcb-util, libxcb-icccm and libxcb-xinerama.
__
cc_libs @xcb_libs;

use_ppport;

# needed for the XS-autogeneration
configure_requires 'XML::Simple' => '0.00';
configure_requires 'List::Util'  => '0.00';
configure_requires 'autodie'     => '0.00';

test_requires 'Test::More';
test_requires 'Test::Deep';
test_requires 'Test::Exception';

requires 'Moose';
requires 'Try::Tiny';

my %xcb = $PC->find('xcb');
my %xcb_xinerama = $PC->find('xcb-xinerama');
my $xml_path = $PC->variable('xcb-proto', 'xcbincludedir');

_GenerateMyXS::generate($xml_path, qw/xproto.xml xinerama.xml/);

print "Loading enums.list...\n";
my $enums = _GenerateMyXS::slurp('enums.list');
print "Replacing in lib/X11/XCB.pm.in\n";
my $libfile = _GenerateMyXS::slurp('lib/X11/XCB.pm.in');
$libfile =~ s/ENUMS_REPLACE_ME/qw($enums)/g;

_GenerateMyXS::spit('lib/X11/XCB.pm', $libfile);

WriteAll;
