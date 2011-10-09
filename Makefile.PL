use strict; use warnings;
my (@configure_req, @author_req);
BEGIN{
  @configure_req = qw/
    Module::Install
    Module::Install::AuthorRequires
    Module::Install::XSUtil
    ExtUtils::PkgConfig
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

require ExtUtils::PkgConfig;
require ExtUtils::Depends;

ExtUtils::PkgConfig->atleast_version('xcb', '1.2')
  or die "You need at least libxcb version 1.2\n";

my @xcb_libs = qw/xcb xcb-util xcb-xinerama xcb-icccm /;
@xcb_libs == grep { eval { ExtUtils::PkgConfig->find($_); 1 } } @xcb_libs
  or die "Perhaps you haven't installed the development versions?\n";

cc_libs @xcb_libs;

if ($Module::Install::AUTHOR or $ENV{X11_XCB_GENERATE}) {
  eval { ExtUtils::PkgConfig->find('xcb-proto'); 1 }
    or die "Please install xcb-proto to provide the required XML protocol definition\n";

  require _GenerateMyXS;
  _GenerateMyXS::generate();
}

WriteMakefile(
  ExtUtils::Depends
    ->new('X11::XCB', 'XS::Object::Magic')
    ->get_makefile_vars
);

# vim:sw=2:sts=2:et
