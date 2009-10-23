use inc::Module::Install;
use FileHandle;
use IO::Handle;
use autodie;
use lib '.';
use _GenerateMyXS;

use ExtUtils::PkgConfig;

# reads in a whole file
sub slurp {
	open my $fh, '<', shift;
	local $/;
	<$fh>;
}

# spits out a file
sub spit {
	open my $fh, '>', shift;
	$fh->print($_) for @_;
}


name 'X11-XCB';
all_from 'lib/X11/XCB.pm.in';

# we need pkg-config to find xcb-proto when generating XS
requires_external_bin 'pkg-config';

cc_append_to_libs qw(xcb xcb-xinerama);

# needed for the XS-autogeneration
configure_requires 'XML::Simple' => '0.00';
configure_requires 'List::Util'  => '0.00';
configure_requires 'autodie'     => '0.00';
configure_requires 'ExtUtils::PkgConfig' => '0.00';

test_requires 'Test::More';
test_requires 'Test::Deep';

requires 'Moose';
requires 'Try::Tiny';

use_test_base;

# XXX check for minimum xcb-version (1.2)
my $pc = 'ExtUtils::PkgConfig';
my %xcb = $pc->find('xcb');
my %xcb_xinerama = $pc->find('xcb-xinerama');
my $xml_path = $pc->variable('xcb-proto', 'xcbincludedir');

_GenerateMyXS::generate($xml_path, qw/xproto.xml xinerama.xml/);

print "Loading enums.list...\n";
my $enums = slurp('enums.list');
print "Replacing in lib/X11/XCB.pm.in\n";
my $libfile = slurp('lib/X11/XCB.pm.in');
$libfile =~ s/ENUMS_REPLACE_ME/qw($enums)/g;

spit('lib/X11/XCB.pm', $libfile);

WriteAll;
