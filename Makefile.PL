use strict; use warnings;

# Automated testing of this module makes little sense: It requires libXau,
# libXdmcp, python2.6 and xsltproc which are typically not installed on CPAN
# smokers.
exit 0 if $ENV{AUTOMATED_TESTING};

my (@configure_req, @author_req);
BEGIN{
  @configure_req = qw/
    Module::Install
    Module::Install::AuthorRequires
    Module::Install::XSUtil
    ExtUtils::Depends
    XS::Object::Magic
  /;
  @author_req = qw/
    XML::Simple
    XML::Descent
    Data::Dump
    autodie
  /;
  my %ok;

  die << '__' . (join "\n", grep { not $ok{$_} } keys %ok) . << '__'
You're running me in author mode.
Your fellow developer left a message to inform you
to please install the following packages manually:

__


Afterwards you can use your CPAN client to install the remaining dependencies,
build this module and install it (eg. `cpanm .`).
__
    if -e '.git'
       and (@configure_req + @author_req)
           != grep { $ok{$_} = eval "require $_; 1" } @configure_req, @author_req;
}

use inc::Module::Install;

name 'X11-XCB';
all_from 'lib/X11/XCB.pm';

repository 'git://code.stapelberg.de/X11-XCB';

requires 'Mouse';
requires 'MouseX::NativeTraits';
requires 'Try::Tiny';

test_requires 'Test::More';
test_requires 'Test::Deep';
test_requires 'Test::Exception';

configure_requires $_ for grep !/Module::Install/, @configure_req;

author_requires $_ for @author_req;

use_ppport;

# -Wunused-value generates too much output to use it unconditionally
cc_warnings if $ENV{X11_XCB_CC_WARNINGS};

require ExtUtils::Depends;

cc_include_paths 'bundled-libs/libxcb-1.8.1/src';

# We link the bundled xcb libraries statically so we don’t have to install them
# on the system (that might not be possible due to missing permissions).
makemaker_args->{MYEXTLIB} = join(' ', qw(
  bundled-libs/libxcb-1.8.1/src/.libs/libxcb.a
  bundled-libs/libxcb-1.8.1/src/.libs/libxcb-xinerama.a
));
makemaker_args->{LDLOADLIBS} = '-lXau -lXdmcp';

{
    package MY;
    sub postamble {
        <<'__EOF__';
$(MYEXTLIB):
	echo "xcbincludedir=$$(pwd)/bundled-libs/xcb-proto-1.7.1/src" > bundled-libs/xcb-proto.pc
	echo "pythondir=$$(pwd)/bundled-libs/xcb-proto-1.7.1/" >> bundled-libs/xcb-proto.pc
	echo "" >> bundled-libs/xcb-proto.pc
	echo "Name: XCB Proto" >> bundled-libs/xcb-proto.pc
	echo "Description: X protocol descriptions for XCB" >> bundled-libs/xcb-proto.pc
	echo "Version: 1.7.1" >> bundled-libs/xcb-proto.pc
	cd bundled-libs/libxcb-1.8.1/ && PKG_CONFIG_PATH=$$(pwd)/.. ./configure --with-pic --disable-shared \
	--disable-composite      \
	--disable-damage         \
	--disable-dpms           \
	--disable-dri2           \
	--disable-glx            \
	--disable-randr          \
	--disable-record         \
	--disable-render         \
	--disable-resource       \
	--disable-screensaver    \
	--disable-shape          \
	--disable-shm            \
	--disable-sync           \
	--disable-xevie          \
	--disable-xfixes         \
	--disable-xfree86-dri    \
	--disable-xinput         \
	--disable-xkb            \
	--disable-xprint         \
	--disable-selinux        \
	--disable-xtest          \
	--disable-xv             \
	--disable-xvmc && $(MAKE)

__EOF__
    }
}

if ($Module::Install::AUTHOR or $ENV{X11_XCB_GENERATE}) {
  require _GenerateMyXS;
  _GenerateMyXS::generate();
}

WriteMakefile(
  ExtUtils::Depends
    ->new('X11::XCB', 'XS::Object::Magic')
    ->get_makefile_vars
);

# vim:sw=2:sts=2:et
