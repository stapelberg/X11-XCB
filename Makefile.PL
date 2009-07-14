use inc::Module::Install;

name 'X11-XCB';

# we need pkg-config to find xcb-proto when generating XS
requires_external_bin 'pkg-config';

test_requires 'Test::More';

use_test_base;

build_subdirs 'X11-XCB-XS';

WriteAll;
