# author needs Module::Install::{AuthorRequires,XSUtil}
use strict; use warnings;
use inc::Module::Install;

name 'X11-XCB';
all_from 'lib/X11/XCB.pm';

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
# cc_warnings; -Wunused-value

use_ppport;

configure_requires 'XS::Object::Magic';
configure_requires 'ExtUtils::Depends';
require ExtUtils::Depends;

test_requires 'Test::More';
test_requires 'Test::Deep';
test_requires 'Test::Exception';

requires 'Mouse';
requires 'MouseX::NativeTraits';
requires 'Try::Tiny';

# needed for the XS-autogeneration
author_requires 'XML::Simple';
author_requires 'XML::Descent';
author_requires 'Data::Dump';
author_requires 'autodie';

if ($Module::Install::AUTHOR) {
    require _GenerateMyXS;
    _GenerateMyXS::generate();
}

WriteMakefile(
    ExtUtils::Depends
        ->new('X11::XCB', 'XS::Object::Magic')
        ->get_makefile_vars
);
