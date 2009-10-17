# XXX workaround: don't re-import subs if called by toplevel Makefile.PL
use ExtUtils::MakeMaker ();
use strict;
use warnings;
use autodie;
use ExtUtils::PkgConfig;
use IO::Handle;

use lib '.';
use _GenerateMyXS;

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

my $pc = 'ExtUtils::PkgConfig';

# XXX check for minimum xcb-version (1.2)
my %xcb = $pc->find('xcb');
my %xcb_xinerama = $pc->find('xcb-xinerama');
my $xml_path = $pc->variable('xcb-proto', 'xcbincludedir');

_GenerateMyXS::generate($xml_path, qw/xproto.xml xinerama.xml/);

print "Loading enums.list...\n";
my $enums = slurp('enums.list');
print "Replacing in lib/X11/XCB.pm.in\n";
my $libfile = slurp("lib/X11/XCB.pm.in");
$libfile =~ s/ENUMS_REPLACE_ME/qw($enums)/g;

spit('lib/X11/XCB.pm', $libfile);

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
ExtUtils::MakeMaker::WriteMakefile(
    NAME              => 'X11::XCB',
    VERSION_FROM      => 'lib/X11/XCB.pm', # finds $VERSION
    PREREQ_PM => {
	    'XML::Simple' => '0.00',
	    'List::Util' => '0.00',
	    'autodie' => '0.00',
	    'ExtUtils::PkgConfig' => '0.00',
            'Test::More' => '0.00',
            'Moose' => '0.00',
            'MooseX::Singleton' => '0.00',
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/X11/XCB.pm', # retrieve abstract from module
       AUTHOR         => 'Michael Stapelberg <michael@>') : ()),
    LIBS              => [ "$xcb{libs} $xcb_xinerama{libs}" ],
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => "-I. $xcb{cflags} $xcb_xinerama{cflags}", # e.g., '-I. -I/usr/include/other'
);
