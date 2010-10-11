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
use autodie;
use Data::Dumper;
use File::Basename qw(basename);
use List::Util qw(first);
use List::MoreUtils qw(uniq);

use XML::Simple qw(:strict);

# reads in a whole file
sub slurp {
	open my $fh, '<', shift;
	local $/;
	<$fh>;
}


my $prefix = 'xcb_';

# In contrary to %xcbtype, which only holds basic data types like 'int', 'char'
# and so on, the %exacttype hash holds the real type name, like INT16 or CARD32
# for any type which has been specified in the XML definition. For example,
# type KEYCODE is an alias for CARD32. This is necessary later on to correctly
# typecast our intArray type.
my %exacttype = (
);

my %xcbtype = (
    BOOL => 'int',
    BYTE => 'int',
    CARD8 => 'int',
    CARD16 => 'int',
    CARD32 => 'int',
    INT8 => 'int',
    INT16 => 'int',
    INT32 => 'int',

    char => 'char',
    void => 'void',  # Hack, to partly support ChangeProperty, until we can reverse 'op'.
    float => 'double',
    double => 'double',
);

my %luatype = (
    BOOL => 'boolean',
    BYTE => 'integer',
    CARD8 => 'integer',
    CARD16 => 'integer',
    CARD32 => 'integer',
    INT8 => 'integer',
    INT16 => 'integer',
    INT32 => 'integer',

    char => 'integer',
    void => 'integer',  # Hack, to partly support ChangeProperty, until we can reverse 'op'.
    float => 'number',
    double => 'number',
);

my %luachecktype = (
    BOOL => 'LUA_TBOOLEAN',
    BYTE => 'LUA_TNUMBER',
    CARD8 => 'LUA_TNUMBER',
    CARD16 => 'LUA_TNUMBER',
    CARD32 => 'LUA_TNUMBER',
    INT8 => 'LUA_TNUMBER',
    INT16 => 'LUA_TNUMBER',
    INT32 => 'LUA_TNUMBER',

    char => 'LUA_TNUMBER',
    void => 'LUA_TNIL',
    float => 'LUA_TNUMBER',
    double => 'LUA_TNUMBER',
);

sub mangle($;$)
{
    my %simple = (
    CHAR2B => 1,
    INT64 => 1,
    FLOAT32 => 1,
    FLOAT64 => 1,
    BOOL32 => 1,
    STRING8 => 1,
    Family_DECnet => 1,
    DECnet => 1
    );
    my ($name, $clean) = @_;
    my $mangled = '';

    $mangled = $prefix unless $clean;

    # FIXME: eliminate this special case
    if ($name =~ /^CUT_BUFFER/) {
        return $name;
    }

    return $mangled . lc($name) if $simple{$name};

    while (length ($name)) {
        my ($char, $next) = ($name =~ /^(.)(.*)$/);

        $mangled .= lc($char);

        if (
        $name =~ /^[[:lower:]][[:upper:]]/ ||
        $name =~ /^\d[[:alpha:]]/ ||
        $name =~ /^[[:alpha:]]\d/ ||
        $name =~ /^[[:upper:]][[:upper:]][[:lower:]]/)
        {
            $mangled .= '_';
        }

        $name = $next;
    }

    return $mangled;
}

sub cname($)
{
    my %bad = (
    new => 1,
    delete => 1,
    class => 1,
    operator => 1 );
    my $name = shift;
    return "_$name" if ($bad{$name});
    return $name;
}

sub do_push($$;$)
{
    my $indent = ' ' x ((shift) * 4);
    my $type = shift;
    my $name = shift;

    my $base;

    if (defined($name)) {
    $base = "x->".cname($name);
    } else {
    $base = "i.data";
    }

    if ($luatype{$type}) {
    # elemental type
    $base = '*'.$base if (!defined($name));
    print OUT $indent."lua_push".$luatype{$type}."(L, $base);\n";
    } else {
    # complex type
    $base = '&'.$base if (defined($name));
    print OUT $indent."push_$type(L, $base);\n";
    }
}

sub do_structs($)
{
    my $xcb = shift;
    foreach my $struct (@{$xcb->{'struct'}}) {
    my $name = $struct->{'name'};
    my $xcbname = mangle($name).'_t';
    my $perlname = $xcbname;
    $perlname =~ s/^xcb_([a-z])/XCB\u$1/g;
    $perlname =~ s/_t$//g;
    print OUTTD " typedef $xcbname $perlname;\n";
    print OUTTM "$perlname * T_PTROBJ\n";

    print OUT "MODULE = X11::XCB PACKAGE = $perlname\n";
    print OUT "$perlname *\nnew(self,";
    my @f;
    foreach my $field (@{$struct->{'field'}}) {
        push @f, $field->{'name'};
    }
    print OUT (join ',', @f);
    print OUT ")\n    char *self\n";
#   foreach my $field (@{$struct->{'field'}}) {
#       print OUT "    $field->{'name'}\n";
#   }
    foreach my $var (@{$struct->{'field'}}) {
        print OUT "    ".get_vartype($var->{'type'})." ";
        print OUT $var->{'name'}."\n";
    }

    print OUT "  PREINIT:\n    $perlname *buf;\n";
    print OUT "  CODE:\n    New(0, buf, 1, $perlname);\n";
    foreach my $var (@{$struct->{'field'}}) {
        print OUT "    buf->" . cname($var->{name}) . " = " . ($var->{name}) . ";\n";
    }
    print OUT "    RETVAL = buf;\n  OUTPUT:\n    RETVAL\n\n";




    my $dogetter = 1;

    my %nostatic = ( # These structs are used from the base protocol
        xcb_setup_t => 1,
    );

    if ($struct->{'list'}) {
        $dogetter = 0;  # If it has a list, the get half shouldn't (can't?) be needed.
#       foreach my $list (@{$struct->{'list'}}) {
#       do_push_list(1, $name, $list->{'type'}, $list->{'name'}, $list->{'value'});
#       }
    }
    #print OUT "}\n\n";

    if ($dogetter) {
        print OUT "MODULE = X11::XCB PACKAGE = $perlname" . "Ptr\n\n";
        foreach my $var (@{$struct->{'field'}}) {
            print OUT "".get_vartype($var->{'type'})."\n";
            print OUT $var->{'name'}."(self)\n";
            print OUT "    $perlname * self\n";
            print OUT "  CODE:\n    RETVAL = self->" . cname($var->{name}) . ";\n  OUTPUT:\n    RETVAL\n\n";
        }

    }
    }
#    foreach my $union (@{$xcb->{'union'}}) {
#   my $name = $union->{'name'};
#   my $xcbname = mangle($name).'_t';
#
#   print OUT "static ";
#   print OUT "void push_$name (lua_State *L, const $xcbname *x)\n";
#   print OUT "{\n";
#   print OUT "    lua_newtable(L);\n";
#   foreach my $field (@{$union->{'field'}}) {
#       my $fn = $field->{'name'};
#       do_push(1, $field->{'type'}, $fn);
#       print OUT "    lua_setfield(L, -2, \"$fn\");\n";
#   }
#   if ($union->{'list'}) {
#       foreach my $list (@{$union->{'list'}}) {
#       do_push_list(1, $name, $list->{'type'}, $list->{'name'}, $list->{'value'});
#       }
#   }
#   print OUT "}\n\n";
#    }
}

sub do_typedefs($)
{
    my $xcb = shift;
    foreach my $tdef (@{$xcb->{'typedef'}}) {
    $xcbtype{$tdef->{'newname'}} = $xcbtype{$tdef->{'oldname'}};
    $luatype{$tdef->{'newname'}} = $luatype{$tdef->{'oldname'}};
    $luachecktype{$tdef->{'newname'}} = $luachecktype{$tdef->{'oldname'}};
    $exacttype{$tdef->{newname}} = $tdef->{oldname};
    }
    foreach my $tdef (@{$xcb->{'xidtype'}}) {
    $xcbtype{$tdef->{'name'}} = $xcbtype{'CARD32'};
    $luatype{$tdef->{'name'}} = $luatype{'CARD32'};
    $luachecktype{$tdef->{'name'}} = $luachecktype{'CARD32'};
    }
    foreach my $tdef (@{$xcb->{'xidunion'}}) {
    $xcbtype{$tdef->{'name'}} = $xcbtype{'CARD32'};
    $luatype{$tdef->{'name'}} = $luatype{'CARD32'};
    $luachecktype{$tdef->{'name'}} = $luachecktype{'CARD32'};
    }
}

sub get_vartype($)
{
    my $type = shift;
    return $xcbtype{$type} if (defined ($xcbtype{$type}));
    return mangle($type)."_t";
}

sub do_requests($\%)
{
    my $xcb = shift;
    my $func = shift;

    foreach my $req (@{$xcb->{'request'}}) {
    my $mangled = mangle($req->{name});
    my $stripped = $mangled;
    $stripped =~ s/^xcb_//g;

    #print Dumper($req);
    my $cookie = mangle($req->{'name'})."_cookie_t";
    if (!defined($req->{reply})) {
        $cookie = "xcb_void_cookie_t";
    }

    # Function header
    print OUT "HV *\n";
    print OUT "$stripped(";
    # all parameter names
    my @param_names = ('conn');

    push @param_names, $_->{name} for @{$req->{field}};
    foreach my $var (@{$req->{'list'}}) {
    if (!defined($var->{'fieldref'}) && !defined($var->{'op'}) && !defined($var->{'value'})) {
        push @param_names, $var->{name} . "_len";
    }
    push @param_names, $var->{name};
    }

    foreach my $var (@{$req->{'valueparam'}}) {
        push @param_names, $var->{'value-mask-name'};
        push @param_names, $var->{'value-list-name'};
        push @param_names, '...';
    }


    print OUT (join ',', uniq @param_names);
    print OUT ")\n";


    # Declare variables
#   if (defined($req->{'reply'})) {
#       print OUT "    $cookie *cookie;\n";
#   }
    print OUT "    XCBConnection *conn\n";

    my @vars;
    foreach my $var (@{$req->{'field'}}) {
        my $type = get_vartype($var->{type});
        if ($type =~ /^xcb_/) {
            $type =~ s/^xcb_/XCB/;
        }
        push @vars, "$type $var->{name}";
    }

    if (defined($req->{'list'})) {
        foreach my $var (@{$req->{'list'}}) {
        if (!defined($var->{'fieldref'}) && !defined($var->{'op'}) && !defined($var->{'value'})) {
            print OUT "    int ";
            print OUT $var->{'name'}."_len\n";
        }
        my $type = get_vartype($var->{type});
        if ($type =~ /^xcb_/) {
            $type =~ s/^xcb_([a-z])/XCB\u$1/g;
            $type =~ s/_t$//g;
        }

        $type = 'intArray' if ($type eq 'int');
        # We use char* instead of void* to be able to use pack() in the perl part
        $type = 'char' if ($type eq 'void');

        push @vars, "$type * $var->{name}";
        }
    }
    if (defined($req->{'valueparam'})) {
        foreach my $var (@{$req->{'valueparam'}}) {
            push @vars, get_vartype($var->{'value-mask-type'}) . " $var->{'value-mask-name'}";
            push @vars, "intArray * $var->{'value-list-name'}";
        }
    }

    print OUT join("\n", uniq @vars) . "\n";

    print OUT "  PREINIT:\n    HV * hash;\n    $cookie cookie;\n";

    print OUT "  CODE:\n";

#   # Read variables from lua
#   print OUT "    c = ((xcb_connection_t **)luaL_checkudata(L, 1, \"XCB.display\"))[0];\n";
#   my $index = 1;
#   foreach my $var (@{$req->{'field'}}) {
#       do_get(++$index, $var->{'type'}, $var->{'name'});
#   }
#   if (defined($req->{'list'})) {
#       foreach my $var (@{$req->{'list'}}) {
#       if (!defined($var->{'fieldref'}) && !defined($var->{'op'}) && !defined($var->{'value'})) {
#           # do_get(++$index, 'CARD32', $var->{'name'}."_len");
#           do_get_list(++$index, $var->{'type'}, $var->{'name'}, 1);
#       } else {
#           do_get_list(++$index, $var->{'type'}, $var->{'name'});
#       }
#       }
#   }
#   if (defined($req->{'valueparam'})) {
#       foreach my $var (@{$req->{'valueparam'}}) {
#       do_get(++$index, $var->{'value-mask-type'}, $var->{'value-mask-name'});
#       do_get_list(++$index, 'CARD32', $var->{'value-list-name'});
#       }
#   }
#   print OUT "\n";



    # Function call
    print OUT "    ";
    if (defined($req->{'reply'})) {
        print OUT "cookie = ";
    }
    print OUT mangle($req->{'name'})."(";

    my @params = ('conn->conn');

    map { push @params, $_->{name} } @{$req->{field}};

    if (defined($req->{'list'})) {
        foreach my $var (@{$req->{'list'}}) {
            if (!defined($var->{'fieldref'}) && !defined($var->{'op'}) && !defined($var->{'value'})) {
                push @params, $var->{name} . '_len';
            }
            my $type = $var->{type};
            $type = $exacttype{$type} if (defined($exacttype{$type}));
            my $t = '';
            if ((my $type_name, my $int_len) = ($type =~ /(INT|CARD)(8|16|32)/)) {
                $t = " (const uint" . $int_len . "_t*)";
            }
            if ($var->{type} eq 'BYTE') {
                $t = " (const uint8_t*)";
            }
            push @params, $t . $var->{name};
        }
    }
    if (defined($req->{'valueparam'})) {
        foreach my $var (@{$req->{'valueparam'}}) {
            push @params, $var->{'value-mask-name'};
            push @params, $var->{'value-list-name'};
        }
    }

    print OUT join(', ', uniq @params) . ");\n\n";

    print OUT "    hash = newHV();\n    hv_store(hash, \"sequence\", strlen(\"sequence\"), newSViv(cookie.sequence), 0);\n";
    print OUT "    RETVAL = hash;\n";

    # Cleanup
    if (defined($req->{'list'})) {
        foreach my $var (@{$req->{'list'}}) {
        if ($var->{'type'} ne 'char' and $var->{'type'} ne 'void') {
            print OUT "    free(". $var->{'name'}.");\n";
        }
        }
    }

    if (defined($req->{'valueparam'})) {
        foreach my $var (@{$req->{'valueparam'}}) {
        print OUT "    free(". $var->{'value-list-name'}.");\n";
        }
    }

    my $retcount = 0;
    $retcount = 1 if (defined($req->{'reply'}));
    print OUT "  OUTPUT:\n    RETVAL\n\n";

    my $manglefunc = mangle($req->{'name'}, 1);
    $func->{$manglefunc} = $req->{'name'};
    }
}

sub do_events($)
{
    my $xcb = shift;
    my %events;

    # TODO: events

#    foreach my $event (@{$xcb->{'event'}}) {
#   my $xcbev = mangle($event->{'name'})."_event_t";
#   print OUT "/* This function adds the remaining fields into the table\n  that is on the top of the stack */\n";
#   print OUT "static void set_";
#   print OUT $event->{'name'};
#   print OUT "(lua_State *L, xcb_generic_event_t *event)\n{\n";
#   print OUT "    $xcbev *x = ($xcbev *)event;\n";
#   foreach my $var (@{$event->{'field'}}) {
#       my $name = $var->{'name'};
#       do_push(1, $var->{'type'}, $name);
#       print OUT "    lua_setfield(L, -2, \"$name\");\n";
#   }
#   print OUT "}\n\n";
#   $events{$event->{'number'}} = 'set_'.$event->{'name'};
#    }
#
#    foreach my $event (@{$xcb->{'eventcopy'}}) {
#   $events{$event->{'number'}} = 'set_'.$event->{'ref'};
#    }
#
#    print OUT "static void init_events()\n{\n";
#    foreach my $i (sort { $a <=> $b } keys %events) {
#   print OUT "    RegisterEvent($i, $events{$i});\n";
#    }
#    print OUT "}\n\n";
}

sub do_replies($\%\%)
{
    my ($xcb, $func, $collect) = @_;

    for my $req (@{$xcb->{request}}) {
        my $rep = $req->{reply};
        next unless defined($rep);

        my $name = mangle($req->{'name'}) . "_reply";
        my $reply = mangle($req->{'name'}) . "_reply_t";
        my $perlname = $name;
        $perlname =~ s/^xcb_//g;
        my $cookie = mangle($req->{name}) . "_cookie_t";

        print OUT "HV *\n$perlname(conn,sequence)\n";
        print OUT "    XCBConnection *conn\n";
        print OUT "    int sequence\n";
        print OUT "  PREINIT:\n";
        print OUT "    HV * hash;\n";
        print OUT "    HV * inner_hash;\n";
        print OUT "    AV * alist;\n";
        print OUT "    int c;\n";
        print OUT "    $cookie cookie;\n";
        print OUT "    $reply *reply;\n";
        print OUT "  CODE:\n";
        print OUT "    cookie.sequence = sequence;\n";
        print OUT "    reply = $name(conn->conn, cookie, NULL);\n";
        print OUT "    hash = newHV();\n";
        # We ignore pad0 and response_type. Every reply has sequence and length
        print OUT "    hv_store(hash, \"sequence\", strlen(\"sequence\"), newSViv(reply->sequence), 0);\n";
        print OUT "    hv_store(hash, \"length\", strlen(\"length\"), newSViv(reply->length), 0);\n";
        foreach my $var (@{$rep->[0]->{'field'}}) {
            my $type = get_vartype($var->{type});
            my $name = cname($var->{name});
            if ($type eq 'int') {
                print OUT "    hv_store(hash, \"$name\", strlen(\"$name\"), newSViv(reply->$name), 0);\n";
            } else {
                print OUT "    /* TODO: type $type, name $var->{name} */\n";
            }
        }

        for my $list (@{$rep->[0]->{list}}) {
            my $listname = $list->{name};
            my $type = mangle($list->{type}) . '_t';
            my $iterator = mangle($list->{type}) . '_iterator_t';
            my $iterator_next = mangle($list->{type}) . '_next';
            my $pre = mangle($req->{name});

            # Get the type description of the list’s members
            my $struct = first { $_->{name} eq $list->{type} } @{$xcb->{struct}};

            next unless defined($struct->{field}) && scalar(@{$struct->{field}}) > 0;

            print OUT "    {\n";
            print OUT "    /* Handling list part of the reply */\n";
            print OUT "    alist = newAV();\n";
            print OUT "    $iterator iterator = $pre" . '_' . $listname . "_iterator(reply);\n";
            print OUT "    for (; iterator.rem > 0; $iterator_next(&iterator)) {\n";
            print OUT "      $type *data = iterator.data;\n";
            print OUT "      inner_hash = newHV();\n";

            for my $field (@{$struct->{field}}) {
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

sub do_enums($)
{
    my $xcb = shift;

    foreach my $enum (@{$xcb->{'enum'}}) {
        my $name = uc(mangle($enum->{'name'}, 1));
        foreach my $item (@{$enum->{'item'}}) {
            my $tname = $name . "_" . uc(mangle($item->{'name'}, 1));
            print OUT "    newCONSTSUB(stash, \"$tname\", newSViv(XCB_$tname));\n";
            print OUTENUMS "$tname\n";
        }
    }

    # Events
    foreach my $event (@{$xcb->{'event'}}) {
        my $number = $event->{'number'};
        my $name = uc(mangle($event->{'name'}, 1));
        print OUT "    newCONSTSUB(stash, \"$name\", newSViv(XCB_$name));\n";
        print OUTENUMS "$name\n";
    }

    # Our own additions: EWMH constants
    print OUT "    newCONSTSUB(stash, \"_NET_WM_STATE_ADD\", newSViv(1));\n";
    print OUTENUMS "_NET_WM_STATE_ADD\n";

    print OUT "    newCONSTSUB(stash, \"_NET_WM_STATE_REMOVE\", newSViv(0));\n";
    print OUTENUMS "_NET_WM_STATE_REMOVE\n";

    print OUT "    newCONSTSUB(stash, \"_NET_WM_STATE_TOGGLE\", newSViv(2));\n";
    print OUTENUMS "_NET_WM_STATE_TOGGLE\n";

    #
    #foreach my $event (@{$xcb->{'eventcopy'}}) {
    #    my $name = $event->{'name'};
    #    my $number = $event->{'number'};
    #    print OUT "    lua_pushinteger(L, $number);\n";
    #    print OUT "    lua_setfield(L, -2, \"$name\");\n";
    #}
    #print OUT "    lua_setfield(L, -2, \"event\");\n";
    #
    ## Errors
    #print OUT "\n    lua_newtable(L);\n";
    #foreach my $error (@{$xcb->{'error'}}) {
    #    my $name = $error->{'name'};
    #    my $number = $error->{'number'};
    #    print OUT "    lua_pushinteger(L, $number);\n";
    #    print OUT "    lua_setfield(L, -2, \"$name\");\n";
    #}
    #
    #foreach my $error (@{$xcb->{'errorcopy'}}) {
    #    my $name = $error->{'name'};
    #    my $number = $error->{'number'};
    #    print OUT "    lua_pushinteger(L, $number);\n";
    #    print OUT "    lua_setfield(L, -2, \"$name\");\n";
    #}
    #print OUT "    lua_setfield(L, -2, \"error\");\n";
    #
    #print OUT "}\n\n";
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

    open(OUT, ">XCB.xs");
    open(OUTTM, ">typemap");
    open(OUTENUMS, ">enums.list");

    print OUTTM "XCBConnection * T_PTROBJ\n";
    print OUTTM "intArray * T_ARRAY\n";
    print OUTTM "X11_XCB_ICCCM_WMHints * T_PTROBJ\n";
    print OUTTM "X11_XCB_ICCCM_SizeHints * T_PTROBJ\n";

    print OUT << 'eot';
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <xcb/xcb.h>
#include <xcb/xinerama.h>
#include <xcb/xcb_icccm.h>
#include "wrapper.h"

#include "ppport.h"
eot

    for my $name (@files) {
        my $bname = basename($name);
        $bname =~ s/\.xml$//;
        print OUT qq|#include "$bname.typedefs"\n|;
    }

    print OUT << 'eot';

typedef struct my_xcb_conn XCBConnection;
typedef xcb_wm_hints_t X11_XCB_ICCCM_WMHints;
typedef xcb_size_hints_t X11_XCB_ICCCM_SizeHints;
typedef int intArray;

intArray *intArrayPtr(int num) {
        intArray *array;

        New(0, array, num, intArray);

        return array;
}
eot

    my $ext = slurp('XCB_util.inc');
    print OUT $ext;

    print OUT << 'eot';

MODULE = X11::XCB PACKAGE = X11::XCB

BOOT:
{
    HV *stash = gv_stashpvn("X11::XCB", strlen("X11::XCB"), TRUE);
eot

    for my $name (@files) {
        my $xcb = XMLin($name, KeyAttr => undef, ForceArray => 1);
        if ($name =~ /xproto/) {
            $prefix = 'xcb_';
        } else {
            $prefix = 'xcb_' . basename($name) . '_';
            $prefix =~ s/\.xml$//;
        }
        do_enums($xcb);
    }

    print OUT << 'eot';
}


XCBConnection *
new(class,displayname,screenp)
    char *class
    const char *displayname
    int screenp = NO_INIT
  PREINIT:
    XCBConnection *xcbconnbuf;
  CODE:
    New(0, xcbconnbuf, 1, XCBConnection);
    xcbconnbuf->conn = xcb_connect(displayname, &screenp);
    RETVAL = xcbconnbuf;
  OUTPUT:
    screenp
    RETVAL

MODULE = X11::XCB PACKAGE = XCBConnectionPtr

int
has_error(self)
    XCBConnection * self
  CODE:
    RETVAL = xcb_connection_has_error(self->conn);
  OUTPUT:
    RETVAL

eot

    foreach my $name (@files) {
        my $path = $name;
        $name =~ s/\.xml$//;
        $name = basename($name);

        my $xcb = XMLin("$path", KeyAttr => undef, ForceArray => 1);

        open(OUTTD, ">$name.typedefs");


        if ($name =~ /xproto/) {
            $prefix = 'xcb_';
        } else {
            $prefix = 'xcb_' . basename($name) . '_';
            $prefix =~ s/\.xml$//;
        }

        my %functions;
        my %collectors;
        do_typedefs($xcb);
        do_structs($xcb);
        do_events($xcb);
        print OUT "MODULE = X11::XCB PACKAGE = XCBConnectionPtr\n";
        do_requests($xcb, %functions);
        do_replies($xcb, %functions, %collectors);
    }

    # convenience functions
    print OUT << 'eot';
int
get_root_window(conn)
    XCBConnection *conn
  CODE:
    RETVAL = xcb_setup_roots_iterator(xcb_get_setup(conn->conn)).data->root;
  OUTPUT:
    RETVAL


int
generate_id(conn)
    XCBConnection *conn
  CODE:
    RETVAL = xcb_generate_id(conn->conn);
  OUTPUT:
    RETVAL

void
flush(conn)
    XCBConnection *conn
  CODE:
    xcb_flush(conn->conn);

eot

    close OUT;
    close OUTTM;
    close OUTENUMS;
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
