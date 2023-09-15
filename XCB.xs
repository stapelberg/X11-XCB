#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <xcb/xcb.h>
#include <xcb/xinerama.h>
#include <xcb/randr.h>
#include <xcb/xkb.h>

#include "ppport.h"

#include "typedefs.h"
#include "xs_object_magic.h"

typedef xcb_connection_t XCBConnection;

/* copied from xcb-util */

typedef enum {
XCB_ICCCM_SIZE_HINT_US_POSITION = 1 << 0,
  XCB_ICCCM_SIZE_HINT_US_SIZE = 1 << 1,
  XCB_ICCCM_SIZE_HINT_P_POSITION = 1 << 2,
  XCB_ICCCM_SIZE_HINT_P_SIZE = 1 << 3,
  XCB_ICCCM_SIZE_HINT_P_MIN_SIZE = 1 << 4,
  XCB_ICCCM_SIZE_HINT_P_MAX_SIZE = 1 << 5,
  XCB_ICCCM_SIZE_HINT_P_RESIZE_INC = 1 << 6,
  XCB_ICCCM_SIZE_HINT_P_ASPECT = 1 << 7,
  XCB_ICCCM_SIZE_HINT_BASE_SIZE = 1 << 8,
  XCB_ICCCM_SIZE_HINT_P_WIN_GRAVITY = 1 << 9
  } xcb_icccm_size_hints_flags_t;

typedef enum {
  XCB_ICCCM_WM_STATE_WITHDRAWN = 0,
  XCB_ICCCM_WM_STATE_NORMAL = 1,
  XCB_ICCCM_WM_STATE_ICONIC = 3
} xcb_icccm_wm_state_t;

typedef enum {
  XCB_ICCCM_WM_HINT_INPUT = (1L << 0),
  XCB_ICCCM_WM_HINT_STATE = (1L << 1),
  XCB_ICCCM_WM_HINT_ICON_PIXMAP = (1L << 2),
  XCB_ICCCM_WM_HINT_ICON_WINDOW = (1L << 3),
  XCB_ICCCM_WM_HINT_ICON_POSITION = (1L << 4),
  XCB_ICCCM_WM_HINT_ICON_MASK = (1L << 5),
  XCB_ICCCM_WM_HINT_WINDOW_GROUP = (1L << 6),
  XCB_ICCCM_WM_HINT_X_URGENCY = (1L << 8)
} xcb_icccm_wm_t;

typedef struct {
/** Marks which fields in this structure are defined */
int32_t flags;
/** Does this application rely on the window manager to get keyboard
    input? */
  uint32_t input;
  /** See below */
  int32_t initial_state;
  /** Pixmap to be used as icon */
  xcb_pixmap_t icon_pixmap;
  /** Window to be used as icon */
  xcb_window_t icon_window;
  /** Initial position of icon */
  int32_t icon_x, icon_y;
  /** Icon mask bitmap */
  xcb_pixmap_t icon_mask;
  /* Identifier of related window group */
  xcb_window_t window_group;
} X11_XCB_ICCCM_WMHints;

typedef struct {
/** User specified flags */
uint32_t flags;
/** User-specified position */
int32_t x, y;
/** User-specified size */
int32_t width, height;
/** Program-specified minimum size */
int32_t min_width, min_height;
/** Program-specified maximum size */
int32_t max_width, max_height;
/** Program-specified resize increments */
int32_t width_inc, height_inc;
/** Program-specified minimum aspect ratios */
int32_t min_aspect_num, min_aspect_den;
/** Program-specified maximum aspect ratios */
int32_t max_aspect_num, max_aspect_den;
/** Program-specified base size */
int32_t base_width, base_height;
/** Program-specified window gravity */
uint32_t win_gravity;
} X11_XCB_ICCCM_SizeHints;

#include "XCB.inc"

typedef int intArray;

intArray *intArrayPtr(int num) {
        intArray *array;

        New(0, array, num, intArray);

        return array;
}

static SV *
_new_event_object(xcb_generic_event_t *event)
{
    int type;
    char *objname;
    HV* hash = newHV();

    // Some events, for instance from XKB, passing essential data only via pad0 field
    hv_store(hash, "pad0", strlen("pad0"), newSViv(event->pad0), 0);
    hv_store(hash, "response_type", strlen("response_type"), newSViv(event->response_type), 0);
    hv_store(hash, "sequence", strlen("sequence"), newSViv(event->sequence), 0);

    // Strip highest bit (set when the event was generated by another client)
    type = (event->response_type & 0x7F);

    switch (type) {
        case XCB_CREATE_NOTIFY:
        {
            objname = "X11::XCB::Event::CreateNotify";
            xcb_create_notify_event_t *e = (xcb_create_notify_event_t*)event;
            hv_store(hash, "response_type", strlen("response_type"), newSViv(e->response_type), 0);
            hv_store(hash, "sequence", strlen("sequence"), newSViv(e->sequence), 0);
            hv_store(hash, "parent", strlen("parent"), newSViv(e->parent), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "x", strlen("x"), newSViv(e->x), 0);
            hv_store(hash, "y", strlen("y"), newSViv(e->y), 0);
            hv_store(hash, "width", strlen("width"), newSViv(e->width), 0);
            hv_store(hash, "height", strlen("height"), newSViv(e->height), 0);
            hv_store(hash, "border_width", strlen("border_width"), newSViv(e->border_width), 0);
            hv_store(hash, "override_redirect", strlen("override_redirect"), newSViv(e->override_redirect), 0);
        }
        break;

        case XCB_MAP_NOTIFY:
        {
            objname = "X11::XCB::Event::MapNotify";
            xcb_map_notify_event_t *e = (xcb_map_notify_event_t*)event;
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "override_redirect", strlen("override_redirect"), newSViv(e->override_redirect), 0);
        }
        break;

        case XCB_MAP_REQUEST:
        {
            objname = "X11::XCB::Event::MapRequest";
            xcb_map_request_event_t *e = (xcb_map_request_event_t*)event;
            hv_store(hash, "parent", strlen("parent"), newSViv(e->parent), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
        }
        break;

        case XCB_CONFIGURE_NOTIFY:
        {
            objname = "X11::XCB::Event::ConfigureNotify";
            xcb_configure_notify_event_t *e = (xcb_configure_notify_event_t*)event;
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "above_sibling", strlen("above_sibling"), newSViv(e->above_sibling), 0);
            hv_store(hash, "x", strlen("x"), newSViv(e->x), 0);
            hv_store(hash, "y", strlen("y"), newSViv(e->y), 0);
            hv_store(hash, "width", strlen("width"), newSViv(e->width), 0);
            hv_store(hash, "height", strlen("height"), newSViv(e->height), 0);
            hv_store(hash, "border_width", strlen("border_width"), newSViv(e->border_width), 0);
            hv_store(hash, "override_redirect", strlen("override_redirect"), newSViv(e->override_redirect), 0);
        }
        break;

        case XCB_CONFIGURE_REQUEST:
        {
            objname = "X11::XCB::Event::ConfigureRequest";
            xcb_configure_request_event_t *e = (xcb_configure_request_event_t*)event;
            hv_store(hash, "parent", strlen("parent"), newSViv(e->parent), 0);
            hv_store(hash, "stack_mode", strlen("stack_mode"), newSViv(e->stack_mode), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "sibling", strlen("sibling"), newSViv(e->sibling), 0);
            hv_store(hash, "x", strlen("x"), newSViv(e->x), 0);
            hv_store(hash, "y", strlen("x"), newSViv(e->y), 0);
            hv_store(hash, "width", strlen("x"), newSViv(e->width), 0);
            hv_store(hash, "height", strlen("x"), newSViv(e->height), 0);
            hv_store(hash, "border_width", strlen("border_width"), newSViv(e->border_width), 0);
            hv_store(hash, "value_mask", strlen("value_mask"), newSViv(e->value_mask), 0);
        }
        break;

        case XCB_UNMAP_NOTIFY:
        {
            objname = "X11::XCB::Event::UnmapNotify";
            xcb_unmap_notify_event_t *e = (xcb_unmap_notify_event_t*)event;
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "from_configure", strlen("from_configure"), newSViv(e->from_configure), 0);
        }
        break;

        case XCB_DESTROY_NOTIFY:
        {
            objname = "X11::XCB::Event::DestroyNotify";
            xcb_destroy_notify_event_t *e = (xcb_destroy_notify_event_t*)event;
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
        }
        break;

        case XCB_PROPERTY_NOTIFY:
        {
            objname = "X11::XCB::Event::PropertyNotify";
            xcb_property_notify_event_t *e = (xcb_property_notify_event_t*)event;
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "atom", strlen("atom"), newSViv(e->atom), 0);
            hv_store(hash, "time", strlen("time"), newSViv(e->time), 0);
            hv_store(hash, "state", strlen("state"), newSViv(e->state), 0);
        }
        break;

        case XCB_FOCUS_IN:
        case XCB_FOCUS_OUT:
        {
            objname = "X11::XCB::Event::Focus";
            xcb_focus_in_event_t *e = (xcb_focus_in_event_t*)event;
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "mode", strlen("mode"), newSViv(e->mode), 0);
        }
        break;

        case XCB_MOTION_NOTIFY:
        {
            objname = "X11::XCB::Event::MotionNotify";
            xcb_motion_notify_event_t *e = (xcb_motion_notify_event_t*)event;
            hv_store(hash, "time", strlen("time"), newSViv(e->time), 0);
            hv_store(hash, "detail", strlen("detail"), newSViv(e->detail), 0);
            hv_store(hash, "root", strlen("root"), newSViv(e->root), 0);
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "child", strlen("child"), newSViv(e->child), 0);
            hv_store(hash, "root_x", strlen("root_x"), newSViv(e->root_x), 0);
            hv_store(hash, "root_y", strlen("root_y"), newSViv(e->root_y), 0);
            hv_store(hash, "event_x", strlen("event_x"), newSViv(e->event_x), 0);
            hv_store(hash, "event_y", strlen("event_y"), newSViv(e->event_y), 0);
            hv_store(hash, "state", strlen("state"), newSViv(e->state), 0);
            hv_store(hash, "same_screen", strlen("same_screen"), newSViv(e->same_screen), 0);
        }
        break;

        case XCB_CLIENT_MESSAGE:
        {
            objname = "X11::XCB::Event::ClientMessage";
            xcb_client_message_event_t *e = (xcb_client_message_event_t*)event;
            hv_store(hash, "window", strlen("window"), newSViv(e->window), 0);
            hv_store(hash, "type", strlen("type"), newSViv(e->type), 0);
            hv_store(hash, "data", strlen("data"), newSVpvn((const char *)&(e->data), 20), 0);
        }
        break;

        case XCB_KEY_PRESS:
        {
            objname = "X11::XCB::Event::KeyPress";
            xcb_key_press_event_t *e = (xcb_key_press_event_t*)event;
            hv_store(hash, "detail", strlen("detail"), newSViv(e->detail), 0);
            hv_store(hash, "time", strlen("time"), newSViv(e->time), 0);
            hv_store(hash, "root", strlen("root"), newSViv(e->root), 0);
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "child", strlen("child"), newSViv(e->child), 0);
            hv_store(hash, "root_x", strlen("root_x"), newSViv(e->root_x), 0);
            hv_store(hash, "root_y", strlen("root_y"), newSViv(e->root_y), 0);
            hv_store(hash, "event_x", strlen("event_x"), newSViv(e->event_x), 0);
            hv_store(hash, "event_y", strlen("event_y"), newSViv(e->event_y), 0);
            hv_store(hash, "state", strlen("state"), newSViv(e->state), 0);
            hv_store(hash, "same_screen", strlen("same_screen"), newSViv(e->same_screen), 0);
        }
        break;

        case XCB_KEY_RELEASE:
        {
            objname = "X11::XCB::Event::KeyRelease";
            xcb_key_release_event_t *e = (xcb_key_release_event_t*)event;
            hv_store(hash, "detail", strlen("detail"), newSViv(e->detail), 0);
            hv_store(hash, "time", strlen("time"), newSViv(e->time), 0);
            hv_store(hash, "root", strlen("root"), newSViv(e->root), 0);
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "child", strlen("child"), newSViv(e->child), 0);
            hv_store(hash, "root_x", strlen("root_x"), newSViv(e->root_x), 0);
            hv_store(hash, "root_y", strlen("root_y"), newSViv(e->root_y), 0);
            hv_store(hash, "event_x", strlen("event_x"), newSViv(e->event_x), 0);
            hv_store(hash, "event_y", strlen("event_y"), newSViv(e->event_y), 0);
            hv_store(hash, "state", strlen("state"), newSViv(e->state), 0);
            hv_store(hash, "same_screen", strlen("same_screen"), newSViv(e->same_screen), 0);
        }
        break;

        case XCB_BUTTON_PRESS:
        case XCB_BUTTON_RELEASE:
        {
            objname = "X11::XCB::Event::ButtonPressRelease";
            xcb_button_press_event_t *e = (xcb_button_press_event_t*)event;
            hv_store(hash, "detail", strlen("detail"), newSViv(e->detail), 0);
            hv_store(hash, "time", strlen("time"), newSViv(e->time), 0);
            hv_store(hash, "root", strlen("root"), newSViv(e->root), 0);
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "child", strlen("child"), newSViv(e->child), 0);
            hv_store(hash, "root_x", strlen("root_x"), newSViv(e->root_x), 0);
            hv_store(hash, "root_y", strlen("root_y"), newSViv(e->root_y), 0);
            hv_store(hash, "event_x", strlen("event_x"), newSViv(e->event_x), 0);
            hv_store(hash, "event_y", strlen("event_y"), newSViv(e->event_y), 0);
            hv_store(hash, "state", strlen("state"), newSViv(e->state), 0);
            hv_store(hash, "same_screen", strlen("same_screen"), newSViv(e->same_screen), 0);
        }
        break;

        case XCB_ENTER_NOTIFY:
        case XCB_LEAVE_NOTIFY:
        {
            objname = "X11::XCB::Event::EnterLeaveNotify";
            xcb_enter_notify_event_t *e = (xcb_enter_notify_event_t*)event;
            hv_store(hash, "detail", strlen("detail"), newSViv(e->detail), 0);
            hv_store(hash, "time", strlen("time"), newSViv(e->time), 0);
            hv_store(hash, "root", strlen("root"), newSViv(e->root), 0);
            hv_store(hash, "event", strlen("event"), newSViv(e->event), 0);
            hv_store(hash, "child", strlen("child"), newSViv(e->child), 0);
            hv_store(hash, "root_x", strlen("root_x"), newSViv(e->root_x), 0);
            hv_store(hash, "root_y", strlen("root_y"), newSViv(e->root_y), 0);
            hv_store(hash, "event_x", strlen("event_x"), newSViv(e->event_x), 0);
            hv_store(hash, "event_y", strlen("event_y"), newSViv(e->event_y), 0);
            hv_store(hash, "state", strlen("state"), newSViv(e->state), 0);
            hv_store(hash, "mode", strlen("mode"), newSViv(e->mode), 0);
            hv_store(hash, "same_screen_focus", strlen("same_screen_focus"), newSViv(e->same_screen_focus), 0);
        }
        break;

        default:
            objname = "X11::XCB::Event::Generic";
            break;
    }


    return sv_bless(newRV_noinc((SV*)hash), gv_stashpv(objname, 1));
}


MODULE = X11::XCB PACKAGE = X11::XCB

BOOT:
{
    HV *stash = gv_stashpvn("X11::XCB", strlen("X11::XCB"), FALSE);
    HV *export_tags = get_hv("X11::XCB::EXPORT_TAGS", FALSE);
    SV **export_tags_all = hv_fetch(export_tags, "all", strlen("all"), 0);
    SV *tmpsv;
    AV *tags_all;

    if (!(export_tags_all &&
        SvROK(*export_tags_all) &&
        (tmpsv = (SV*)SvRV(*export_tags_all)) &&
        SvTYPE(tmpsv) == SVt_PVAV &&
        (tags_all = (AV*)tmpsv)))
    {
        croak("$EXPORT_TAGS{all} is not an array reference");
    }

    boot_constants(stash, tags_all);
}

void
_connect_and_attach_struct(self)
    SV *self
  PREINIT:
    XCBConnection *xcbconnbuf;
  CODE:
    assert(sv_derived_from(self, HvNAME(PL_curstash)));
    SV **disp = hv_fetch((HV*)SvRV(self), "display", strlen("display"), 0);
    if(!disp)
        croak("Attribute 'display' is required");

    const char *displayname = SvPV_nolen(*disp);
    int screenp;

    xcbconnbuf = xcb_connect(displayname, &screenp);
    /* XXX: error checking */
    xs_object_magic_attach_struct(aTHX_ SvRV(self), xcbconnbuf);

void
DESTROY(self)
    XCBConnection *self
  CODE:
    Safefree(self);

int
has_error(self)
    XCBConnection * self
  CODE:
    RETVAL = xcb_connection_has_error(self);
  OUTPUT:
    RETVAL


int
get_file_descriptor(self)
    XCBConnection * self
  CODE:
    RETVAL = xcb_get_file_descriptor(self);
  OUTPUT:
    RETVAL

void *
get_xcb_conn(self)
    SV * self
  CODE:
    RETVAL = xs_object_magic_get_struct_rv(aTHX_ self);
  OUTPUT:
    RETVAL

SV *
wait_for_event(self)
    XCBConnection * self
  PREINIT:
    HV * hash;
    SV * result;
    xcb_generic_event_t * event;
  CODE:
    event = xcb_wait_for_event(self);
    if (event == NULL) {
        RETVAL = &PL_sv_undef;
    } else {
        RETVAL = _new_event_object(event);
    }
  OUTPUT:
    RETVAL


SV *
poll_for_event(self)
    XCBConnection * self
  PREINIT:
    HV * hash;
    SV * result;
    xcb_generic_event_t * event;
  CODE:
    event = xcb_poll_for_event(self);
    if (event == NULL) {
        RETVAL = &PL_sv_undef;
    } else {
        RETVAL = _new_event_object(event);
    }
  OUTPUT:
    RETVAL


SV *
get_setup(conn)
    XCBConnection *conn
  PREINIT:
    HV * hash;
    const xcb_setup_t * setup;
  CODE:
    hash = newHV();
    setup = xcb_get_setup(conn);
    if (setup) {
        hv_store(hash, "status", strlen("status"), newSViv(setup->status), 0);
        hv_store(hash, "protocol_major_version", strlen("protocol_major_version"), newSViv(setup->protocol_major_version), 0);
        hv_store(hash, "protocol_minor_version", strlen("protocol_minor_version"), newSViv(setup->protocol_minor_version), 0);
        hv_store(hash, "length", strlen("length"), newSViv(setup->length), 0);
        hv_store(hash, "release_number", strlen("release_number"), newSViv(setup->release_number), 0);
        hv_store(hash, "resource_id_base", strlen("resource_id_base"), newSViv(setup->resource_id_base), 0);
        hv_store(hash, "resource_id_mask", strlen("resource_id_mask"), newSViv(setup->resource_id_mask), 0);
        hv_store(hash, "motion_buffer_size", strlen("motion_buffer_size"), newSViv(setup->motion_buffer_size), 0);
        hv_store(hash, "vendor_len", strlen("vendor_len"), newSViv(setup->vendor_len), 0);
        hv_store(hash, "maximum_request_length", strlen("maximum_request_length"), newSViv(setup->maximum_request_length), 0);
        hv_store(hash, "roots_len", strlen("roots_len"), newSViv(setup->roots_len), 0);
        hv_store(hash, "pixmap_formats_len", strlen("pixmap_formats_len"), newSViv(setup->pixmap_formats_len), 0);
        hv_store(hash, "image_byte_order", strlen("image_byte_order"), newSViv(setup->image_byte_order), 0);
        hv_store(hash, "bitmap_format_bit_order", strlen("bitmap_format_bit_order"), newSViv(setup->bitmap_format_bit_order), 0);
        hv_store(hash, "bitmap_format_scanline_unit", strlen("bitmap_format_scanline_unit"), newSViv(setup->bitmap_format_scanline_unit), 0);
        hv_store(hash, "bitmap_format_scanline_pad", strlen("bitmap_format_scanline_pad"), newSViv(setup->bitmap_format_scanline_pad), 0);
        hv_store(hash, "min_keycode", strlen("min_keycode"), newSViv(setup->min_keycode), 0);
        hv_store(hash, "max_keycode", strlen("max_keycode"), newSViv(setup->max_keycode), 0);
        RETVAL = sv_bless(newRV_noinc((SV*)hash), gv_stashpv("X11::XCB::Setup", 1));
    } else {
        RETVAL = &PL_sv_undef;
    }
  OUTPUT:
    RETVAL

SV *
get_keymap(conn)
    XCBConnection *conn
  PREINIT:
    AV * row;
    SSize_t idx;
    const xcb_setup_t * setup;
    int i;
    int j;
    int total_codes;
    xcb_get_keyboard_mapping_reply_t * kmap;
    xcb_keysym_t * keysym;
  INIT:
    AV * results = (AV *)sv_2mortal((SV *)newAV());
    av_extend(results, 256);
  CODE:
    setup = xcb_get_setup(conn);
    if (! setup || setup->max_keycode > 255 || setup->min_keycode >= setup->max_keycode)
      croak("Failed calling xcb_get_setup()");

    kmap = xcb_get_keyboard_mapping_reply(conn, xcb_get_keyboard_mapping(conn, setup->min_keycode, setup->max_keycode - setup->min_keycode + 1), 0);
    total_codes = kmap->length / kmap->keysyms_per_keycode;
    keysym = xcb_get_keyboard_mapping_keysyms(kmap);

    if (! keysym)
      croak("Failed getting X11 keyboard mapping");

    for (int i = 0; i < total_codes; i++) {
      idx = setup->min_keycode + i;
      row = (AV *)sv_2mortal((SV *)newAV());
      av_extend(row, kmap->keysyms_per_keycode);

      for (int j = 0; j < kmap->keysyms_per_keycode; j++) {
        if (! av_store(row, j, newSViv(keysym[j + i * kmap->keysyms_per_keycode]))) {
          XSRETURN_UNDEF;
        }
      }

      if (! av_store(results, idx, newRV_inc((SV *)row))) {
        XSRETURN_UNDEF;
      }
    }

    RETVAL = newRV_inc((SV *)results);
  OUTPUT:
    RETVAL

SV *
get_query_tree_children(conn, window)
    XCBConnection *conn
    uint32_t window
  PREINIT:
    xcb_query_tree_cookie_t cookie;
    xcb_query_tree_reply_t *reply;
    xcb_window_t *children;
    int children_len;
  INIT:
    AV * results = (AV *)sv_2mortal((SV *)newAV());
  CODE:
    cookie = xcb_query_tree(conn, window);
    reply = xcb_query_tree_reply(conn, cookie, NULL);
    if (! reply)
      croak("Failed calling xcb_query_tree()");
    if (! (children_len = xcb_query_tree_children_length(reply)))
      XSRETURN_UNDEF;
    av_extend(results, children_len);
    children = xcb_query_tree_children(reply);
    for (int i = 0; i < children_len; i++) {
      if (! av_store(results, i, newSViv(children[i]))) {
        XSRETURN_UNDEF;
      }
    }
    RETVAL = newRV_inc((SV *)results);
  OUTPUT:
    RETVAL

int
get_root_window(conn)
    XCBConnection *conn
  CODE:
    RETVAL = xcb_setup_roots_iterator(xcb_get_setup(conn)).data->root;
  OUTPUT:
    RETVAL

int
generate_id(conn)
    XCBConnection *conn
  CODE:
    RETVAL = xcb_generate_id(conn);
  OUTPUT:
    RETVAL

void
flush(conn)
    XCBConnection *conn
  CODE:
    xcb_flush(conn);

int
extension_present(conn, extension_name)
    XCBConnection *conn
    char *extension_name
  CODE:
    xcb_extension_t *ext = NULL;
    if (strcmp(extension_name, "xinerama") == 0) {
      ext = &xcb_xinerama_id;
    }
    if (ext != NULL) {
      const xcb_query_extension_reply_t *reply;
      reply = xcb_get_extension_data(conn, ext);
      RETVAL = reply->present;
    } else {
      RETVAL = 0;
    }
  OUTPUT:
    RETVAL

# XXX There is no _checked sign in xproto.xml, so adding some functions manually

HV *
request_check(conn, sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_generic_error_t *error;
    xcb_void_cookie_t cookie;
  CODE:
    cookie.sequence = sequence;
    error = xcb_request_check(conn, cookie);
    if (! error)
      XSRETURN_UNDEF;
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(error->sequence), 0);
    hv_store(hash, "response_type", strlen("response_type"), newSViv(error->response_type), 0);
    hv_store(hash, "error_code", strlen("error_code"), newSViv(error->error_code), 0);
    hv_store(hash, "resource_id", strlen("resource_id"), newSViv(error->resource_id), 0);
    hv_store(hash, "minor_code", strlen("minor_code"), newSViv(error->minor_code), 0);
    hv_store(hash, "major_code", strlen("major_code"), newSViv(error->major_code), 0);
    hv_store(hash, "full_sequence", strlen("full_sequence"), newSViv(error->full_sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_window_attributes_checked(conn, window, value_mask, value_list, ...)
    XCBConnection *conn
    uint32_t window
    uint32_t value_mask
    intArray * value_list
  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    cookie = xcb_change_window_attributes_checked(conn, window, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

INCLUDE: XCB_util.inc

INCLUDE: XCB_xs.inc
