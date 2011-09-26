#!/usr/bin/perl
# vim:ts=4:sw=4:expandtab

# Known bugs:
# - Does not support _checked or _unchecked variants of function calls
# - Allows Lua to underflow and (maybe) crash C, when it should lua_error instead (so pcall can catch it)
# - ChangeProperty is limited to the 8-bit datatype

# Known warts:
# - Should get string lengths (and other lengths) from Lua, instead of requiring the length to be passed from the script

package _GenerateMyXS;

use warnings;
use strict;
use v5.10;
use autodie;
use Data::Dump;
use File::Basename qw(basename);
use List::Util qw(first);
use List::MoreUtils qw(uniq);
use Try::Tiny;
use ExtUtils::PkgConfig;

use XML::Simple qw(:strict);

use XML::Descent;
my $parser;
sub on {
    my ($tag, $code) = @_;
    $parser->on($tag => sub { $code->(@_) for $_[1] });
}
sub walk { $parser->walk }

# reads in a whole file
sub slurp {
    open my $fh, '<', shift;
    local $/;
    <$fh>;
}

sub spit {
    open my $fh, '>', shift;
    print $fh @_;
}

my $prefix = 'xcb_';
my %consts;

# In contrary to %xcbtype, which only holds basic data types like 'int', 'char'
# and so on, the %exacttype hash holds the real type name, like INT16 or CARD32
# for any type which has been specified in the XML definition. For example,
# type KEYCODE is an alias for CARD32. This is necessary later on to correctly
# typecast our intArray type.
my %exacttype = ();

my %xcbtype = (
    BOOL   => 'int',
    BYTE   => 'int',
    CARD8  => 'int',
    CARD16 => 'int',
    CARD32 => 'int',
    INT8   => 'int',
    INT16  => 'int',
    INT32  => 'int',

    char   => 'char',
    void   => 'void',     # Hack, to partly support ChangeProperty, until we can reverse 'op'.
    float  => 'double',
    double => 'double',
);

my %luatype = (
    BOOL   => 'boolean',
    BYTE   => 'integer',
    CARD8  => 'integer',
    CARD16 => 'integer',
    CARD32 => 'integer',
    INT8   => 'integer',
    INT16  => 'integer',
    INT32  => 'integer',

    char   => 'integer',
    void   => 'integer',    # Hack, to partly support ChangeProperty, until we can reverse 'op'.
    float  => 'number',
    double => 'number',
);

my %luachecktype = (
    BOOL   => 'LUA_TBOOLEAN',
    BYTE   => 'LUA_TNUMBER',
    CARD8  => 'LUA_TNUMBER',
    CARD16 => 'LUA_TNUMBER',
    CARD32 => 'LUA_TNUMBER',
    INT8   => 'LUA_TNUMBER',
    INT16  => 'LUA_TNUMBER',
    INT32  => 'LUA_TNUMBER',

    char   => 'LUA_TNUMBER',
    void   => 'LUA_TNIL',
    float  => 'LUA_TNUMBER',
    double => 'LUA_TNUMBER',
);

our $level = 1;
sub indent (&$@) {
    my ($code, $join, @input) = @_;
    my $indent = ' ' x ($level * 4);

    return join $join, map { $indent . $code->() } @input;
}

sub tmpl_struct {
    my ($name, $params, $types) = @_;

    my $constructor = 'new';

    my $param = join ',', @$params;
    my $param_decl = indent { "$types->{$_} $_" } "\n", @$params;
    my $set_struct = indent { 'buf->' . cname($_) . " = $_;" } "\n", @$params;

    return << "__"
MODULE = X11::XCB PACKAGE = $name
$name *
$constructor(self,$param)
    char *self
$param_decl
  PREINIT:
    $name *buf;
  CODE:
    New(0, buf, 1, $name);
$set_struct
    RETVAL = buf;
  OUTPUT:
    RETVAL

__
}

sub tmpl_struct_getter {
    my ($pkg, $name, $type) = @_;
    my $cname = cname($name);

    return << "__"
$type
$name(self)
    $pkg * self
  CODE:
    RETVAL = self->$cname;
  OUTPUT:
    RETVAL

__
}

sub tmpl_request {
    my ($name, $cookie, $params, $types, $xcb_cast, $cleanups) = @_;

    my $param = join ',', ('conn', @$params);
    my @param = grep { $_ ne '...' } @$params;

    my $param_decl = indent { "$types->{$_} $_" } "\n", @param;

    my $xcb_name = "xcb_$name";
    my $xcb_param = do {
        local $level = 0;
        $xcb_cast->{'conn->conn'} = '';
        indent { $xcb_cast->{$_} . $_ } ', ', ('conn->conn', @param);
    };
    my $cleanup = indent { "free($_);" } "\n", @$cleanups;

    return << "__"
HV *
$name($param)
    XCBConnection *conn
$param_decl
  PREINIT:
    HV * hash;
    $cookie cookie;
  CODE:
    cookie = $xcb_name($xcb_param);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
$cleanup
  OUTPUT:
    RETVAL

__
}

sub xcb_name($;$) {
    my ($name, $clean) = @_;

    my %simple = (
        CHAR2B        => 1,
        INT64         => 1,
        FLOAT32       => 1,
        FLOAT64       => 1,
        BOOL32        => 1,
        STRING8       => 1,
        Family_DECnet => 1,
        DECnet        => 1
    );
    my $mangled = '';

    $mangled = $prefix unless $clean;

    # FIXME: eliminate this special case
    if ($name =~ /^CUT_BUFFER/) {
        return $name;
    }

    return $mangled . lc($name) if $simple{$name};

    while (length($name)) {
        my ($char, $next) = ($name =~ /^(.)(.*)$/);

        $mangled .= lc($char);

        if (   $name =~ /^[[:lower:]][[:upper:]]/
            || $name =~ /^\d[[:alpha:]]/
            || $name =~ /^[[:alpha:]]\d/
            || $name =~ /^[[:upper:]][[:upper:]][[:lower:]]/)
        {
            $mangled .= '_';
        }

        $name = $next;
    }

    return $mangled;
}

sub cname($) {
    my $name = shift;

    my %bad = (
        new      => 1,
        delete   => 1,
        class    => 1,
        operator => 1
    );

    return "_$name" if $bad{$name};
    return $name;
}

sub do_push($$;$) {
    my $indent = ' ' x ((shift) * 4);
    my $type   = shift;
    my $name   = shift;

    my $base;

    if (defined($name)) {
        $base = "x->" . cname($name);
    } else {
        $base = "i.data";
    }

    if ($luatype{$type}) {

        # elemental type
        $base = '*' . $base if (!defined($name));
        print OUT $indent . "lua_push" . $luatype{$type} . "(L, $base);\n";
    } else {

        # complex type
        $base = '&' . $base if (defined($name));
        print OUT $indent . "push_$type(L, $base);\n";
    }
}

sub do_structs($) {
    my $xcb = shift;

    for my $struct (@{ $xcb->{struct} }) {
        my $name     = $struct->{name};
        my $xcbname  = xcb_name($name) . '_t';
        my $perlname = $xcbname;
        $perlname =~ s/^xcb_([a-z])/XCB\u$1/g;
        $perlname =~ s/_t$//g;
        print OUTTD " typedef $xcbname $perlname;\n";
        print OUTTM "$perlname * T_PTROBJ\n";

        my @fields;
        my %type = map {
            # keep order in @fields
            push @fields, $_->{name};

            ( $_->{name} => get_vartype($_->{type}) )
        } @{ $struct->{field} };

        print OUT tmpl_struct($perlname, \@fields, \%type);

        my $dogetter = 1;

        my %nostatic = (    # These structs are used from the base protocol
            xcb_setup_t => 1,
        );

        if ($struct->{list}) {
            $dogetter = 0;    # If it has a list, the get half shouldn't (can't?) be needed.

#       for my $list (@{$struct->{list}}) {
#       do_push_list(1, $name, $list->{type}, $list->{name}, $list->{value});
#       }
        }

        if ($dogetter) {
            print OUT "MODULE = X11::XCB PACKAGE = $perlname" . "Ptr\n\n";
            print OUT tmpl_struct_getter($perlname, $_, $type{$_}) for @fields;

        }
    }

#    for my $union (@{$xcb->{union}}) {
#   my $name = $union->{name};
#   my $xcbname = xcb_name($name).'_t';
#
#   print OUT "static ";
#   print OUT "void push_$name (lua_State *L, const $xcbname *x)\n";
#   print OUT "{\n";
#   print OUT "    lua_newtable(L);\n";
#   for my $field (@{$union->{field}}) {
#       my $fn = $field->{name};
#       do_push(1, $field->{type}, $fn);
#       print OUT "    lua_setfield(L, -2, \"$fn\");\n";
#   }
#   if ($union->{list}) {
#       for my $list (@{$union->{list}}) {
#       do_push_list(1, $name, $list->{type}, $list->{name}, $list->{value});
#       }
#   }
#   print OUT "}\n\n";
#    }
}

sub do_typedefs {
    my $e = shift;

    if ($e eq 'typedef') {
        $xcbtype{ $_->{newname} }      = $xcbtype{ $_->{oldname} };
        $luatype{ $_->{newname} }      = $luatype{ $_->{oldname} };
        $luachecktype{ $_->{newname} } = $luachecktype{ $_->{oldname} };
        $exacttype{ $_->{newname} }    = $_->{oldname};
    }
    elsif ($e =~ /^(?:xidtype|xidunion)/) {
        $xcbtype{ $_->{name} }      = $xcbtype{CARD32};
        $luatype{ $_->{name} }      = $luatype{CARD32};
        $luachecktype{ $_->{name} } = $luachecktype{CARD32};
    }
}

sub get_vartype($) {
    my $type = shift;

    return $xcbtype{$type} if (defined($xcbtype{$type}));
    return xcb_name($type) . "_t";
}

sub do_requests($\%) {
    my ($xcb, $func)  = @_;

    for my $req (@{ $xcb->{request} }) {
        my $xcb_name  = xcb_name($req->{name});
        (my $name = $xcb_name) =~ s/^xcb_//g;

        my $cookie = ($req->{reply} ? $xcb_name : 'xcb_void' ) . '_cookie_t';

        my @param_names = map $_->{name}, @{ $req->{field} };

        for my $var (@{ $req->{list} }) {
            if (!$var->{fieldref} && !$var->{op} && !$var->{value}) {
                push @param_names, $var->{name} . "_len";
            }
            push @param_names, $var->{name};
        }

        for my $var (@{ $req->{valueparam} }) {
            push @param_names, $var->{'value-mask-name'};
            push @param_names, $var->{'value-list-name'};
            push @param_names, '...';
        }

        @param_names = uniq @param_names;

        my %type;
        for my $var (@{ $req->{field} }) {
            my $type = get_vartype($var->{type});
            if ($type =~ /^xcb_/) {
                $type =~ s/^xcb_/XCB/;
            }
            $type{ $var->{name} } = $type;
        }

        for my $var (@{ $req->{list} }) {
            if (!$var->{fieldref} && !$var->{op} && !$var->{value}) {
                $type{ $var->{name} . '_len'} = 'int';
            }
            my $type = get_vartype($var->{type});
            if ($type =~ /^xcb_/) {
                $type =~ s/^xcb_([a-z])/XCB\u$1/g;
                $type =~ s/_t$//g;
            }

            $type = 'intArray' if ($type eq 'int');

            # We use char* instead of void* to be able to use pack() in the perl part
            $type = 'char' if ($type eq 'void');

            $type{ $var->{name} } = "$type *";
        }

        for my $var (@{ $req->{valueparam} }) {
            $type{ $var->{'value-mask-name'} } = get_vartype($var->{'value-mask-type'});
            $type{ $var->{'value-list-name'} } = 'intArray *';
        }

#   # Read variables from lua
#   print OUT "    c = ((xcb_connection_t **)luaL_checkudata(L, 1, \"XCB.display\"))[0];\n";
#   my $index = 1;
#   for my $var (@{$req->{field}}) {
#       do_get(++$index, $var->{type}, $var->{name});
#   }
#   if (defined($req->{list})) {
#       for my $var (@{$req->{list}}) {
#       if (!defined($var->{fieldref}) && !defined($var->{op}) && !defined($var->{value})) {
#           # do_get(++$index, 'CARD32', $var->{name}."_len");
#           do_get_list(++$index, $var->{type}, $var->{name}, 1);
#       } else {
#           do_get_list(++$index, $var->{type}, $var->{name});
#       }
#       }
#   }
#   if (defined($req->{valueparam})) {
#       for my $var (@{$req->{valueparam}}) {
#       do_get(++$index, $var->{'value-mask-type'}, $var->{'value-mask-name'});
#       do_get_list(++$index, 'CARD32', $var->{'value-list-name'});
#       }
#   }
#   print OUT "\n";


        my %xcb_cast;
        @xcb_cast{ @param_names } = ('') x @param_names;
        for my $var (@{ $req->{list} }) {
            my $type = $var->{type};
            $type = $exacttype{$type} if (defined($exacttype{$type}));
            my $t = '';
            if ((my $type_name, my $int_len) = ($type =~ /(INT|CARD)(8|16|32)/)) {
                $t = " (const uint" . $int_len . "_t*)";
            }
            if ($var->{type} eq 'BYTE') {
                $t = " (const uint8_t*)";
            }
            $xcb_cast{ $var->{name} } = $t;
        }

        my @cleanup;
        # Cleanup
        for my $var (@{ $req->{list} }) {
            if ($var->{type} ne 'char' and $var->{type} ne 'void') {
                push @cleanup, $var->{name};
            }
        }

        for my $var (@{ $req->{valueparam} }) {
            push @cleanup, $var->{'value-list-name'};
        }

        print OUT tmpl_request($name, $cookie, \@param_names, \%type, \%xcb_cast, \@cleanup);

    }
}

sub do_events($) {
    my $xcb = shift;
    my %events;

    # TODO: events

#    for my $event (@{$xcb->{event}}) {
#   my $xcbev = xcb_name($event->{name})."_event_t";
#   print OUT "/* This function adds the remaining fields into the table\n  that is on the top of the stack */\n";
#   print OUT "static void set_";
#   print OUT $event->{name};
#   print OUT "(lua_State *L, xcb_generic_event_t *event)\n{\n";
#   print OUT "    $xcbev *x = ($xcbev *)event;\n";
#   for my $var (@{$event->{field}}) {
#       my $name = $var->{name};
#       do_push(1, $var->{type}, $name);
#       print OUT "    lua_setfield(L, -2, \"$name\");\n";
#   }
#   print OUT "}\n\n";
#   $events{$event->{number}} = 'set_'.$event->{name};
#    }
#
#    for my $event (@{$xcb->{eventcopy}}) {
#   $events{$event->{number}} = 'set_'.$event->{ref};
#    }
#
#    print OUT "static void init_events()\n{\n";
#    for my $i (sort { $a <=> $b } keys %events) {
#   print OUT "    RegisterEvent($i, $events{$i});\n";
#    }
#    print OUT "}\n\n";
}

sub do_replies($\%\%) {
    my ($xcb, $func, $collect) = @_;

    for my $req (@{ $xcb->{request} }) {
        my $rep = $req->{reply};
        next unless defined($rep);
        # request should return a cookie object, blessed into the right pkg
        # $perlname should be set fixed to 'reply'

        my $name     = xcb_name($req->{name}) . "_reply";
        my $reply    = xcb_name($req->{name}) . "_reply_t";
        my $perlname = $name;
        $perlname =~ s/^xcb_//g;
        my $cookie = xcb_name($req->{name}) . "_cookie_t";

        print OUT "HV *\n$perlname(conn,sequence)\n";
        print OUT "    XCBConnection *conn\n";
        print OUT "    int sequence\n";
        print OUT "  PREINIT:\n";
        print OUT "    HV * hash;\n";
        print OUT "    HV * inner_hash;\n";
        print OUT "    AV * alist;\n";
        print OUT "    int c;\n";
        print OUT "    int _len;\n";
        print OUT "    $cookie cookie;\n";
        print OUT "    $reply *reply;\n";
        print OUT "  CODE:\n";
        print OUT "    cookie.sequence = sequence;\n";
        print OUT "    reply = $name(conn->conn, cookie, NULL);\n";
        # XXX use connection_has_error
        print OUT qq/    if (!reply) croak("Could not get reply for: $name"); /;
        print OUT "    hash = newHV();\n";

        # We ignore pad0 and response_type. Every reply has sequence and length
        print OUT "    hv_store(hash, \"sequence\", strlen(\"sequence\"), newSViv(reply->sequence), 0);\n";
        print OUT "    hv_store(hash, \"length\", strlen(\"length\"), newSViv(reply->length), 0);\n";
        for my $var (@{ $rep->[0]->{field} }) {
            my $type = get_vartype($var->{type});
            my $name = cname($var->{name});
            if ($type eq 'int') {
                print OUT "    hv_store(hash, \"$name\", strlen(\"$name\"), newSViv(reply->$name), 0);\n";
            } else {
                print OUT "    /* TODO: type $type, name $var->{name} */\n";
            }
        }

        for my $list (@{ $rep->[0]->{list} }) {
            my $listname      = $list->{name};
            my $type          = xcb_name($list->{type}) . '_t';
            my $iterator      = xcb_name($list->{type}) . '_iterator_t';
            my $iterator_next = xcb_name($list->{type}) . '_next';
            my $pre           = xcb_name($req->{name});

            if ($list->{type} eq 'void') {

                # A byte-array. Provide it as SV.
                print OUT "    _len = reply->value_len * (reply->format / 8);\n";
                print OUT "    if (_len > 0)\n";
                print OUT "        hv_store(hash, \"value\", strlen(\"value\"), newSVpvn((const char*)(reply + 1), _len), 0);\n";
                next;
            }

            # Get the type description of the list’s members
            my $struct = first { $_->{name} eq $list->{type} } @{ $xcb->{struct} };

            next unless defined($struct->{field}) && scalar(@{ $struct->{field} }) > 0;

            print OUT "    {\n";
            print OUT "    /* Handling list part of the reply */\n";
            print OUT "    alist = newAV();\n";
            print OUT "    $iterator iterator = $pre" . '_' . $listname . "_iterator(reply);\n";
            print OUT "    for (; iterator.rem > 0; $iterator_next(&iterator)) {\n";
            print OUT "      $type *data = iterator.data;\n";
            print OUT "      inner_hash = newHV();\n";

            for my $field (@{ $struct->{field} }) {
                my $type = get_vartype($field->{type});
                my $name = cname($field->{name});

                if ($type eq 'int') {
                    print OUT "      hv_store(inner_hash, \"$name\", strlen(\"$name\"), newSViv(data->$name), 0);\n";
                } else {
                    print OUT "      /* TODO: type $type, name $name */\n";
                }
            }
            print OUT "      av_push(alist, newRV((SV*)inner_hash));\n";

            print OUT "    }\n";
            print OUT "    hv_store(hash, \"" . $list->{name} . "\", strlen(\"" . $list->{name} . "\"), newRV((SV*)alist), 0);\n";

            print OUT "    }\n";
        }

        #print Dumper($rep);
        #if (defined($rep->{list})) {

        print OUT "    RETVAL = hash;\n";
        print OUT "  OUTPUT:\n    RETVAL\n\n";
    }
}

sub do_enums {
    my ($tag, $attr) = @_;

    my $name = uc(xcb_name($attr->{name}, 1));

    if ($tag eq 'enum') {
        on item => sub {
            my $tname = $name . "_" . uc(xcb_name($_->{name}, 1));
            $consts{$tname} = "newSViv(XCB_$tname)";
        };
        walk;

    }
#    elsif ($tag =~ /^(?:event|eventcopy|error|errorcopy)$/) {
#        my $number = $_->{number};
#        $consts{$name} = "newSViv($number)";
#    }

}

sub generate {
    my ($path, @xcb_xmls) = @_;

    -d $path or die "$path: $!\n";

    # TODO: Handle all .xmls
    #opendir(DIR, '.');
    #@files = grep { /\.xml$/ } readdir(DIR);
    #closedir DIR;

    my @files = map {
        my $xml = "$path/$_";
        -r $xml or die "$xml: $!\n";
        $xml
    } @xcb_xmls;

    open(OUT,   ">XCB_xs.inc");
    open(OUTTM, ">typemap");
    open(OUTTD, ">typedefs.h");

    print OUTTM "XCBConnection * T_PTROBJ\n";
    print OUTTM "intArray * T_ARRAY\n";
    print OUTTM "X11_XCB_ICCCM_WMHints * T_PTROBJ\n";
    print OUTTM "X11_XCB_ICCCM_SizeHints * T_PTROBJ\n";

    # Our own additions: EWMH constants
    $consts{_NET_WM_STATE_ADD}    = 'newSViv(1)';
    $consts{_NET_WM_STATE_REMOVE} = 'newSViv(0)';
    $consts{_NET_WM_STATE_TOGGLE} = 'newSViv(2)';

    # ICCCM constants from xcb-util
    for my $const (qw(XCB_ICCCM_WM_STATE_WITHDRAWN XCB_ICCCM_WM_STATE_NORMAL XCB_ICCCM_WM_STATE_ICONIC)) {
        my ($name) = ($const =~ /XCB_(.*)/);
        $consts{$name} = "newSViv($const)";
    }

    for my $path (@files) {
        my $xcb = XMLin("$path", KeyAttr => undef, ForceArray => 1);

        $parser = XML::Descent->new({ Input => $path });

        on xcb => sub {
            my ($e, $attr) = @_;
            my $name = $attr->{header};
            print "Processing $name: $path\n";

            $prefix = $name eq 'xproto' ? 'xcb_' : "${name}_";

            # on [ qw/enum event eventcopy error errorcopy/ ] => \&do_enums;
            on enum => \&do_enums;
            on [ qw/typedef xidtype xidunion/ ] => \&do_typedefs;
            walk;
        };
        walk;

        my %functions;
        my %collectors;
        do_structs($xcb);
        do_events($xcb);
        print OUT "MODULE = X11::XCB PACKAGE = XCBConnectionPtr\n";
        do_requests($xcb, %functions);
        do_replies($xcb, %functions, %collectors);
    }

    close OUT;
    close OUTTM;
    close OUTTD;

    open my $fh_c, '>', 'XCB.inc';
    print $fh_c "static void boot_constants(HV *stash, AV *tags_all) {\n";
    printf $fh_c qq/    av_extend(tags_all, %d);\n/, scalar keys %consts;
    for my $name (sort keys %consts) {
        printf $fh_c qq/    newCONSTSUB(stash, "%s", %s);\n/,          $name, $consts{$name};
        printf $fh_c qq/    av_push(tags_all, newSVpvn("%s", %d));\n/, $name, length $name;
    }
    print $fh_c "}\n";
    close $fh_c;

}

'The One True Value';

# Copyright (C) 2009 Michael Stapelberg <michael at stapelberg dot de>
# Copyright (C) 2007 Hummingbird Ltd. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall
# be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
# KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the names of the authors
# or their institutions shall not be used in advertising or
# otherwise to promote the sale, use or other dealings in this
# Software without prior written authorization from the
# authors.
