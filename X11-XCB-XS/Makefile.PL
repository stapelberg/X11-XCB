use 5.010000;
use ExtUtils::MakeMaker;
use FindBin;

use IO::All;

my $bin = $FindBin::Bin;
if (not -e "$bin/enums.list") {
	$bin .= "/X11-XCB-XS";
}
print "Loading $bin/enums.list...\n";
my @enums = io("$bin/enums.list")->slurp;
my $enums = join ' ', @enums;
print "Replacing in $bin/lib/X11/XCB.pm.in\n";
my @libfile = io("$bin/lib/X11/XCB.pm.in")->slurp;
for my $line (@libfile) {
        $line =~ s/ENUMS_REPLACE_ME/qw($enums)/g;
}

(join '', @libfile) > io("$bin/lib/X11/XCB.pm");

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'X11::XCB',
    VERSION_FROM      => 'lib/X11/XCB.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/X11/XCB.pm', # retrieve abstract from module
       AUTHOR         => 'Michael Stapelberg <michael@>') : ()),
    LIBS              => [qw(-lxcb)],
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
);
