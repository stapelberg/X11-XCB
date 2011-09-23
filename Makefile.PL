# author needs Module::Install::{AuthorRequires,XSUtil}
use strict; use warnings;
use inc::Module::Install;
use lib '.';
use _GenerateMyXS;

use ExtUtils::PkgConfig;

name 'X11-XCB';
all_from 'lib/X11/XCB.pm.in';

cc_libs qw(xcb xcb-xinerama xcb-icccm);

use_ppport;

# needed for the XS-autogeneration
configure_requires 'XML::Simple' => '0.00';
configure_requires 'List::Util'  => '0.00';
configure_requires 'autodie'     => '0.00';
configure_requires 'ExtUtils::PkgConfig' => '0.00';

test_requires 'Test::More';
test_requires 'Test::Deep';
test_requires 'Test::Exception';

requires 'Moose';
requires 'Try::Tiny';

# XXX check for minimum xcb-version (1.2)
my $pc = 'ExtUtils::PkgConfig';
my %xcb = $pc->find('xcb');
my %xcb_xinerama = $pc->find('xcb-xinerama');
my $xml_path = $pc->variable('xcb-proto', 'xcbincludedir');

_GenerateMyXS::generate($xml_path, qw/xproto.xml xinerama.xml/);

print "Loading enums.list...\n";
my $enums = _GenerateMyXS::slurp('enums.list');
print "Replacing in lib/X11/XCB.pm.in\n";
my $libfile = _GenerateMyXS::slurp('lib/X11/XCB.pm.in');
$libfile =~ s/ENUMS_REPLACE_ME/qw($enums)/g;

_GenerateMyXS::spit('lib/X11/XCB.pm', $libfile);

WriteAll;
