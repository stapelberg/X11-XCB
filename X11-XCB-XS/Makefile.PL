# XXX workaround: don't re-import subs if called by toplevel Makefile.PL
use ExtUtils::MakeMaker ();

use strict; use warnings;
use ExtUtils::PkgConfig;

use IO::All;

use lib '.';
use _GenerateMyXS;

my $pc = 'ExtUtils::PkgConfig';

# XXX specify minimum xcb-version
my %xcb = $pc->find('xcb');
my $xml_path = $pc->variable('xcb-proto', 'xcbincludedir');

# XXX do this always?!
#unless (-e 'enums.list' and -s _) {
	_GenerateMyXS::generate($xml_path, qw/xproto.xml xinerama.xml/);
#}

print "Loading enums.list...\n";
my @enums = io("enums.list")->slurp;
my $enums = join ' ', @enums;
print "Replacing in lib/X11/XCB.pm.in\n";
my @libfile = io("lib/X11/XCB.pm.in")->slurp;
for my $line (@libfile) {
        $line =~ s/^ENUMS_REPLACE_ME/qw($enums)/g and last;
}

(join '', @libfile) > io("lib/X11/XCB.pm");

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
ExtUtils::MakeMaker::WriteMakefile(
    NAME              => 'X11::XCB',
    VERSION_FROM      => 'lib/X11/XCB.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/X11/XCB.pm', # retrieve abstract from module
       AUTHOR         => 'Michael Stapelberg <michael@>') : ()),
    LIBS              => [ "$xcb{libs} -lxcb-xinerama" ],
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => "-I. $xcb{cflags}", # e.g., '-I. -I/usr/include/other'
);
