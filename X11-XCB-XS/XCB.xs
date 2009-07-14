#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <xcb/xcb.h>
#include "wrapper.h"

#include "ppport.h"

#include "xproto.typedefs"

intArray *intArrayPtr(int num) {
        intArray *array;

        New(0, array, num, intArray);

        return array;
}

MODULE = X11::XCB PACKAGE = X11::XCB

BOOT:
{
	HV *stash = gv_stashpvn("X11::XCB", strlen("X11::XCB"), TRUE);
    newCONSTSUB(stash, "VISUAL_CLASS_STATIC_GRAY", newSViv(XCB_VISUAL_CLASS_STATIC_GRAY));
    newCONSTSUB(stash, "VISUAL_CLASS_GRAY_SCALE", newSViv(XCB_VISUAL_CLASS_GRAY_SCALE));
    newCONSTSUB(stash, "VISUAL_CLASS_STATIC_COLOR", newSViv(XCB_VISUAL_CLASS_STATIC_COLOR));
    newCONSTSUB(stash, "VISUAL_CLASS_PSEUDO_COLOR", newSViv(XCB_VISUAL_CLASS_PSEUDO_COLOR));
    newCONSTSUB(stash, "VISUAL_CLASS_TRUE_COLOR", newSViv(XCB_VISUAL_CLASS_TRUE_COLOR));
    newCONSTSUB(stash, "VISUAL_CLASS_DIRECT_COLOR", newSViv(XCB_VISUAL_CLASS_DIRECT_COLOR));
    newCONSTSUB(stash, "IMAGE_ORDER_LSB_FIRST", newSViv(XCB_IMAGE_ORDER_LSB_FIRST));
    newCONSTSUB(stash, "IMAGE_ORDER_MSB_FIRST", newSViv(XCB_IMAGE_ORDER_MSB_FIRST));
    newCONSTSUB(stash, "MOD_MASK_SHIFT", newSViv(XCB_MOD_MASK_SHIFT));
    newCONSTSUB(stash, "MOD_MASK_LOCK", newSViv(XCB_MOD_MASK_LOCK));
    newCONSTSUB(stash, "MOD_MASK_CONTROL", newSViv(XCB_MOD_MASK_CONTROL));
    newCONSTSUB(stash, "MOD_MASK_1", newSViv(XCB_MOD_MASK_1));
    newCONSTSUB(stash, "MOD_MASK_2", newSViv(XCB_MOD_MASK_2));
    newCONSTSUB(stash, "MOD_MASK_3", newSViv(XCB_MOD_MASK_3));
    newCONSTSUB(stash, "MOD_MASK_4", newSViv(XCB_MOD_MASK_4));
    newCONSTSUB(stash, "MOD_MASK_5", newSViv(XCB_MOD_MASK_5));
    newCONSTSUB(stash, "BUTTON_MASK_1", newSViv(XCB_BUTTON_MASK_1));
    newCONSTSUB(stash, "BUTTON_MASK_2", newSViv(XCB_BUTTON_MASK_2));
    newCONSTSUB(stash, "BUTTON_MASK_3", newSViv(XCB_BUTTON_MASK_3));
    newCONSTSUB(stash, "BUTTON_MASK_4", newSViv(XCB_BUTTON_MASK_4));
    newCONSTSUB(stash, "BUTTON_MASK_5", newSViv(XCB_BUTTON_MASK_5));
    newCONSTSUB(stash, "BUTTON_MASK_ANY", newSViv(XCB_BUTTON_MASK_ANY));
    newCONSTSUB(stash, "MOTION_NORMAL", newSViv(XCB_MOTION_NORMAL));
    newCONSTSUB(stash, "MOTION_HINT", newSViv(XCB_MOTION_HINT));
    newCONSTSUB(stash, "NOTIFY_DETAIL_ANCESTOR", newSViv(XCB_NOTIFY_DETAIL_ANCESTOR));
    newCONSTSUB(stash, "NOTIFY_DETAIL_VIRTUAL", newSViv(XCB_NOTIFY_DETAIL_VIRTUAL));
    newCONSTSUB(stash, "NOTIFY_DETAIL_INFERIOR", newSViv(XCB_NOTIFY_DETAIL_INFERIOR));
    newCONSTSUB(stash, "NOTIFY_DETAIL_NONLINEAR", newSViv(XCB_NOTIFY_DETAIL_NONLINEAR));
    newCONSTSUB(stash, "NOTIFY_DETAIL_NONLINEAR_VIRTUAL", newSViv(XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL));
    newCONSTSUB(stash, "NOTIFY_DETAIL_POINTER", newSViv(XCB_NOTIFY_DETAIL_POINTER));
    newCONSTSUB(stash, "NOTIFY_DETAIL_POINTER_ROOT", newSViv(XCB_NOTIFY_DETAIL_POINTER_ROOT));
    newCONSTSUB(stash, "NOTIFY_DETAIL_NONE", newSViv(XCB_NOTIFY_DETAIL_NONE));
    newCONSTSUB(stash, "NOTIFY_MODE_NORMAL", newSViv(XCB_NOTIFY_MODE_NORMAL));
    newCONSTSUB(stash, "NOTIFY_MODE_GRAB", newSViv(XCB_NOTIFY_MODE_GRAB));
    newCONSTSUB(stash, "NOTIFY_MODE_UNGRAB", newSViv(XCB_NOTIFY_MODE_UNGRAB));
    newCONSTSUB(stash, "NOTIFY_MODE_WHILE_GRABBED", newSViv(XCB_NOTIFY_MODE_WHILE_GRABBED));
    newCONSTSUB(stash, "VISIBILITY_UNOBSCURED", newSViv(XCB_VISIBILITY_UNOBSCURED));
    newCONSTSUB(stash, "VISIBILITY_PARTIALLY_OBSCURED", newSViv(XCB_VISIBILITY_PARTIALLY_OBSCURED));
    newCONSTSUB(stash, "VISIBILITY_FULLY_OBSCURED", newSViv(XCB_VISIBILITY_FULLY_OBSCURED));
    newCONSTSUB(stash, "PLACE_ON_TOP", newSViv(XCB_PLACE_ON_TOP));
    newCONSTSUB(stash, "PLACE_ON_BOTTOM", newSViv(XCB_PLACE_ON_BOTTOM));
    newCONSTSUB(stash, "PROPERTY_NEW_VALUE", newSViv(XCB_PROPERTY_NEW_VALUE));
    newCONSTSUB(stash, "PROPERTY_DELETE", newSViv(XCB_PROPERTY_DELETE));
    newCONSTSUB(stash, "COLORMAP_STATE_UNINSTALLED", newSViv(XCB_COLORMAP_STATE_UNINSTALLED));
    newCONSTSUB(stash, "COLORMAP_STATE_INSTALLED", newSViv(XCB_COLORMAP_STATE_INSTALLED));
    newCONSTSUB(stash, "MAPPING_MODIFIER", newSViv(XCB_MAPPING_MODIFIER));
    newCONSTSUB(stash, "MAPPING_KEYBOARD", newSViv(XCB_MAPPING_KEYBOARD));
    newCONSTSUB(stash, "MAPPING_POINTER", newSViv(XCB_MAPPING_POINTER));
    newCONSTSUB(stash, "WINDOW_CLASS_COPY_FROM_PARENT", newSViv(XCB_WINDOW_CLASS_COPY_FROM_PARENT));
    newCONSTSUB(stash, "WINDOW_CLASS_INPUT_OUTPUT", newSViv(XCB_WINDOW_CLASS_INPUT_OUTPUT));
    newCONSTSUB(stash, "WINDOW_CLASS_INPUT_ONLY", newSViv(XCB_WINDOW_CLASS_INPUT_ONLY));
    newCONSTSUB(stash, "CW_BACK_PIXMAP", newSViv(XCB_CW_BACK_PIXMAP));
    newCONSTSUB(stash, "CW_BACK_PIXEL", newSViv(XCB_CW_BACK_PIXEL));
    newCONSTSUB(stash, "CW_BORDER_PIXMAP", newSViv(XCB_CW_BORDER_PIXMAP));
    newCONSTSUB(stash, "CW_BORDER_PIXEL", newSViv(XCB_CW_BORDER_PIXEL));
    newCONSTSUB(stash, "CW_BIT_GRAVITY", newSViv(XCB_CW_BIT_GRAVITY));
    newCONSTSUB(stash, "CW_WIN_GRAVITY", newSViv(XCB_CW_WIN_GRAVITY));
    newCONSTSUB(stash, "CW_BACKING_STORE", newSViv(XCB_CW_BACKING_STORE));
    newCONSTSUB(stash, "CW_BACKING_PLANES", newSViv(XCB_CW_BACKING_PLANES));
    newCONSTSUB(stash, "CW_BACKING_PIXEL", newSViv(XCB_CW_BACKING_PIXEL));
    newCONSTSUB(stash, "CW_OVERRIDE_REDIRECT", newSViv(XCB_CW_OVERRIDE_REDIRECT));
    newCONSTSUB(stash, "CW_SAVE_UNDER", newSViv(XCB_CW_SAVE_UNDER));
    newCONSTSUB(stash, "CW_EVENT_MASK", newSViv(XCB_CW_EVENT_MASK));
    newCONSTSUB(stash, "CW_DONT_PROPAGATE", newSViv(XCB_CW_DONT_PROPAGATE));
    newCONSTSUB(stash, "CW_COLORMAP", newSViv(XCB_CW_COLORMAP));
    newCONSTSUB(stash, "CW_CURSOR", newSViv(XCB_CW_CURSOR));
    newCONSTSUB(stash, "BACK_PIXMAP_NONE", newSViv(XCB_BACK_PIXMAP_NONE));
    newCONSTSUB(stash, "BACK_PIXMAP_PARENT_RELATIVE", newSViv(XCB_BACK_PIXMAP_PARENT_RELATIVE));
    newCONSTSUB(stash, "GRAVITY_BIT_FORGET", newSViv(XCB_GRAVITY_BIT_FORGET));
    newCONSTSUB(stash, "GRAVITY_WIN_UNMAP", newSViv(XCB_GRAVITY_WIN_UNMAP));
    newCONSTSUB(stash, "GRAVITY_NORTH_WEST", newSViv(XCB_GRAVITY_NORTH_WEST));
    newCONSTSUB(stash, "GRAVITY_NORTH", newSViv(XCB_GRAVITY_NORTH));
    newCONSTSUB(stash, "GRAVITY_NORTH_EAST", newSViv(XCB_GRAVITY_NORTH_EAST));
    newCONSTSUB(stash, "GRAVITY_WEST", newSViv(XCB_GRAVITY_WEST));
    newCONSTSUB(stash, "GRAVITY_CENTER", newSViv(XCB_GRAVITY_CENTER));
    newCONSTSUB(stash, "GRAVITY_EAST", newSViv(XCB_GRAVITY_EAST));
    newCONSTSUB(stash, "GRAVITY_SOUTH_WEST", newSViv(XCB_GRAVITY_SOUTH_WEST));
    newCONSTSUB(stash, "GRAVITY_SOUTH", newSViv(XCB_GRAVITY_SOUTH));
    newCONSTSUB(stash, "GRAVITY_SOUTH_EAST", newSViv(XCB_GRAVITY_SOUTH_EAST));
    newCONSTSUB(stash, "GRAVITY_STATIC", newSViv(XCB_GRAVITY_STATIC));
    newCONSTSUB(stash, "BACKING_STORE_NOT_USEFUL", newSViv(XCB_BACKING_STORE_NOT_USEFUL));
    newCONSTSUB(stash, "BACKING_STORE_WHEN_MAPPED", newSViv(XCB_BACKING_STORE_WHEN_MAPPED));
    newCONSTSUB(stash, "BACKING_STORE_ALWAYS", newSViv(XCB_BACKING_STORE_ALWAYS));
    newCONSTSUB(stash, "EVENT_MASK_NO_EVENT", newSViv(XCB_EVENT_MASK_NO_EVENT));
    newCONSTSUB(stash, "EVENT_MASK_KEY_PRESS", newSViv(XCB_EVENT_MASK_KEY_PRESS));
    newCONSTSUB(stash, "EVENT_MASK_KEY_RELEASE", newSViv(XCB_EVENT_MASK_KEY_RELEASE));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_PRESS", newSViv(XCB_EVENT_MASK_BUTTON_PRESS));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_RELEASE", newSViv(XCB_EVENT_MASK_BUTTON_RELEASE));
    newCONSTSUB(stash, "EVENT_MASK_ENTER_WINDOW", newSViv(XCB_EVENT_MASK_ENTER_WINDOW));
    newCONSTSUB(stash, "EVENT_MASK_LEAVE_WINDOW", newSViv(XCB_EVENT_MASK_LEAVE_WINDOW));
    newCONSTSUB(stash, "EVENT_MASK_POINTER_MOTION", newSViv(XCB_EVENT_MASK_POINTER_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_POINTER_MOTION_HINT", newSViv(XCB_EVENT_MASK_POINTER_MOTION_HINT));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_1_MOTION", newSViv(XCB_EVENT_MASK_BUTTON_1_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_2_MOTION", newSViv(XCB_EVENT_MASK_BUTTON_2_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_3_MOTION", newSViv(XCB_EVENT_MASK_BUTTON_3_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_4_MOTION", newSViv(XCB_EVENT_MASK_BUTTON_4_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_5_MOTION", newSViv(XCB_EVENT_MASK_BUTTON_5_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_BUTTON_MOTION", newSViv(XCB_EVENT_MASK_BUTTON_MOTION));
    newCONSTSUB(stash, "EVENT_MASK_KEYMAP_STATE", newSViv(XCB_EVENT_MASK_KEYMAP_STATE));
    newCONSTSUB(stash, "EVENT_MASK_EXPOSURE", newSViv(XCB_EVENT_MASK_EXPOSURE));
    newCONSTSUB(stash, "EVENT_MASK_VISIBILITY_CHANGE", newSViv(XCB_EVENT_MASK_VISIBILITY_CHANGE));
    newCONSTSUB(stash, "EVENT_MASK_STRUCTURE_NOTIFY", newSViv(XCB_EVENT_MASK_STRUCTURE_NOTIFY));
    newCONSTSUB(stash, "EVENT_MASK_RESIZE_REDIRECT", newSViv(XCB_EVENT_MASK_RESIZE_REDIRECT));
    newCONSTSUB(stash, "EVENT_MASK_SUBSTRUCTURE_NOTIFY", newSViv(XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY));
    newCONSTSUB(stash, "EVENT_MASK_SUBSTRUCTURE_REDIRECT", newSViv(XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT));
    newCONSTSUB(stash, "EVENT_MASK_FOCUS_CHANGE", newSViv(XCB_EVENT_MASK_FOCUS_CHANGE));
    newCONSTSUB(stash, "EVENT_MASK_PROPERTY_CHANGE", newSViv(XCB_EVENT_MASK_PROPERTY_CHANGE));
    newCONSTSUB(stash, "EVENT_MASK_COLOR_MAP_CHANGE", newSViv(XCB_EVENT_MASK_COLOR_MAP_CHANGE));
    newCONSTSUB(stash, "EVENT_MASK_OWNER_GRAB_BUTTON", newSViv(XCB_EVENT_MASK_OWNER_GRAB_BUTTON));
    newCONSTSUB(stash, "MAP_STATE_UNMAPPED", newSViv(XCB_MAP_STATE_UNMAPPED));
    newCONSTSUB(stash, "MAP_STATE_UNVIEWABLE", newSViv(XCB_MAP_STATE_UNVIEWABLE));
    newCONSTSUB(stash, "MAP_STATE_VIEWABLE", newSViv(XCB_MAP_STATE_VIEWABLE));
    newCONSTSUB(stash, "SET_MODE_INSERT", newSViv(XCB_SET_MODE_INSERT));
    newCONSTSUB(stash, "SET_MODE_DELETE", newSViv(XCB_SET_MODE_DELETE));
    newCONSTSUB(stash, "CONFIG_WINDOW_X", newSViv(XCB_CONFIG_WINDOW_X));
    newCONSTSUB(stash, "CONFIG_WINDOW_Y", newSViv(XCB_CONFIG_WINDOW_Y));
    newCONSTSUB(stash, "CONFIG_WINDOW_WIDTH", newSViv(XCB_CONFIG_WINDOW_WIDTH));
    newCONSTSUB(stash, "CONFIG_WINDOW_HEIGHT", newSViv(XCB_CONFIG_WINDOW_HEIGHT));
    newCONSTSUB(stash, "CONFIG_WINDOW_BORDER_WIDTH", newSViv(XCB_CONFIG_WINDOW_BORDER_WIDTH));
    newCONSTSUB(stash, "CONFIG_WINDOW_SIBLING", newSViv(XCB_CONFIG_WINDOW_SIBLING));
    newCONSTSUB(stash, "CONFIG_WINDOW_STACK_MODE", newSViv(XCB_CONFIG_WINDOW_STACK_MODE));
    newCONSTSUB(stash, "STACK_MODE_ABOVE", newSViv(XCB_STACK_MODE_ABOVE));
    newCONSTSUB(stash, "STACK_MODE_BELOW", newSViv(XCB_STACK_MODE_BELOW));
    newCONSTSUB(stash, "STACK_MODE_TOP_IF", newSViv(XCB_STACK_MODE_TOP_IF));
    newCONSTSUB(stash, "STACK_MODE_BOTTOM_IF", newSViv(XCB_STACK_MODE_BOTTOM_IF));
    newCONSTSUB(stash, "STACK_MODE_OPPOSITE", newSViv(XCB_STACK_MODE_OPPOSITE));
    newCONSTSUB(stash, "CIRCULATE_RAISE_LOWEST", newSViv(XCB_CIRCULATE_RAISE_LOWEST));
    newCONSTSUB(stash, "CIRCULATE_LOWER_HIGHEST", newSViv(XCB_CIRCULATE_LOWER_HIGHEST));
    newCONSTSUB(stash, "PROP_MODE_REPLACE", newSViv(XCB_PROP_MODE_REPLACE));
    newCONSTSUB(stash, "PROP_MODE_PREPEND", newSViv(XCB_PROP_MODE_PREPEND));
    newCONSTSUB(stash, "PROP_MODE_APPEND", newSViv(XCB_PROP_MODE_APPEND));
    newCONSTSUB(stash, "GET_PROPERTY_TYPE_ANY", newSViv(XCB_GET_PROPERTY_TYPE_ANY));
    newCONSTSUB(stash, "SEND_EVENT_DEST_POINTER_WINDOW", newSViv(XCB_SEND_EVENT_DEST_POINTER_WINDOW));
    newCONSTSUB(stash, "SEND_EVENT_DEST_ITEM_FOCUS", newSViv(XCB_SEND_EVENT_DEST_ITEM_FOCUS));
    newCONSTSUB(stash, "GRAB_MODE_SYNC", newSViv(XCB_GRAB_MODE_SYNC));
    newCONSTSUB(stash, "GRAB_MODE_ASYNC", newSViv(XCB_GRAB_MODE_ASYNC));
    newCONSTSUB(stash, "GRAB_STATUS_SUCCESS", newSViv(XCB_GRAB_STATUS_SUCCESS));
    newCONSTSUB(stash, "GRAB_STATUS_ALREADY_GRABBED", newSViv(XCB_GRAB_STATUS_ALREADY_GRABBED));
    newCONSTSUB(stash, "GRAB_STATUS_INVALID_TIME", newSViv(XCB_GRAB_STATUS_INVALID_TIME));
    newCONSTSUB(stash, "GRAB_STATUS_NOT_VIEWABLE", newSViv(XCB_GRAB_STATUS_NOT_VIEWABLE));
    newCONSTSUB(stash, "GRAB_STATUS_FROZEN", newSViv(XCB_GRAB_STATUS_FROZEN));
    newCONSTSUB(stash, "BUTTON_INDEX_ANY", newSViv(XCB_BUTTON_INDEX_ANY));
    newCONSTSUB(stash, "BUTTON_INDEX_1", newSViv(XCB_BUTTON_INDEX_1));
    newCONSTSUB(stash, "BUTTON_INDEX_2", newSViv(XCB_BUTTON_INDEX_2));
    newCONSTSUB(stash, "BUTTON_INDEX_3", newSViv(XCB_BUTTON_INDEX_3));
    newCONSTSUB(stash, "BUTTON_INDEX_4", newSViv(XCB_BUTTON_INDEX_4));
    newCONSTSUB(stash, "BUTTON_INDEX_5", newSViv(XCB_BUTTON_INDEX_5));
    newCONSTSUB(stash, "GRAB_ANY", newSViv(XCB_GRAB_ANY));
    newCONSTSUB(stash, "ALLOW_ASYNC_POINTER", newSViv(XCB_ALLOW_ASYNC_POINTER));
    newCONSTSUB(stash, "ALLOW_SYNC_POINTER", newSViv(XCB_ALLOW_SYNC_POINTER));
    newCONSTSUB(stash, "ALLOW_REPLAY_POINTER", newSViv(XCB_ALLOW_REPLAY_POINTER));
    newCONSTSUB(stash, "ALLOW_ASYNC_KEYBOARD", newSViv(XCB_ALLOW_ASYNC_KEYBOARD));
    newCONSTSUB(stash, "ALLOW_SYNC_KEYBOARD", newSViv(XCB_ALLOW_SYNC_KEYBOARD));
    newCONSTSUB(stash, "ALLOW_REPLAY_KEYBOARD", newSViv(XCB_ALLOW_REPLAY_KEYBOARD));
    newCONSTSUB(stash, "ALLOW_ASYNC_BOTH", newSViv(XCB_ALLOW_ASYNC_BOTH));
    newCONSTSUB(stash, "ALLOW_SYNC_BOTH", newSViv(XCB_ALLOW_SYNC_BOTH));
    newCONSTSUB(stash, "INPUT_FOCUS_NONE", newSViv(XCB_INPUT_FOCUS_NONE));
    newCONSTSUB(stash, "INPUT_FOCUS_POINTER_ROOT", newSViv(XCB_INPUT_FOCUS_POINTER_ROOT));
    newCONSTSUB(stash, "INPUT_FOCUS_PARENT", newSViv(XCB_INPUT_FOCUS_PARENT));
    newCONSTSUB(stash, "FONT_DRAW_LEFT_TO_RIGHT", newSViv(XCB_FONT_DRAW_LEFT_TO_RIGHT));
    newCONSTSUB(stash, "FONT_DRAW_RIGHT_TO_LEFT", newSViv(XCB_FONT_DRAW_RIGHT_TO_LEFT));
    newCONSTSUB(stash, "GC_FUNCTION", newSViv(XCB_GC_FUNCTION));
    newCONSTSUB(stash, "GC_PLANE_MASK", newSViv(XCB_GC_PLANE_MASK));
    newCONSTSUB(stash, "GC_FOREGROUND", newSViv(XCB_GC_FOREGROUND));
    newCONSTSUB(stash, "GC_BACKGROUND", newSViv(XCB_GC_BACKGROUND));
    newCONSTSUB(stash, "GC_LINE_WIDTH", newSViv(XCB_GC_LINE_WIDTH));
    newCONSTSUB(stash, "GC_LINE_STYLE", newSViv(XCB_GC_LINE_STYLE));
    newCONSTSUB(stash, "GC_CAP_STYLE", newSViv(XCB_GC_CAP_STYLE));
    newCONSTSUB(stash, "GC_JOIN_STYLE", newSViv(XCB_GC_JOIN_STYLE));
    newCONSTSUB(stash, "GC_FILL_STYLE", newSViv(XCB_GC_FILL_STYLE));
    newCONSTSUB(stash, "GC_FILL_RULE", newSViv(XCB_GC_FILL_RULE));
    newCONSTSUB(stash, "GC_TILE", newSViv(XCB_GC_TILE));
    newCONSTSUB(stash, "GC_STIPPLE", newSViv(XCB_GC_STIPPLE));
    newCONSTSUB(stash, "GC_TILE_STIPPLE_ORIGIN_X", newSViv(XCB_GC_TILE_STIPPLE_ORIGIN_X));
    newCONSTSUB(stash, "GC_TILE_STIPPLE_ORIGIN_Y", newSViv(XCB_GC_TILE_STIPPLE_ORIGIN_Y));
    newCONSTSUB(stash, "GC_FONT", newSViv(XCB_GC_FONT));
    newCONSTSUB(stash, "GC_SUBWINDOW_MODE", newSViv(XCB_GC_SUBWINDOW_MODE));
    newCONSTSUB(stash, "GC_GRAPHICS_EXPOSURES", newSViv(XCB_GC_GRAPHICS_EXPOSURES));
    newCONSTSUB(stash, "GC_CLIP_ORIGIN_X", newSViv(XCB_GC_CLIP_ORIGIN_X));
    newCONSTSUB(stash, "GC_CLIP_ORIGIN_Y", newSViv(XCB_GC_CLIP_ORIGIN_Y));
    newCONSTSUB(stash, "GC_CLIP_MASK", newSViv(XCB_GC_CLIP_MASK));
    newCONSTSUB(stash, "GC_DASH_OFFSET", newSViv(XCB_GC_DASH_OFFSET));
    newCONSTSUB(stash, "GC_DASH_LIST", newSViv(XCB_GC_DASH_LIST));
    newCONSTSUB(stash, "GC_ARC_MODE", newSViv(XCB_GC_ARC_MODE));
    newCONSTSUB(stash, "GX_CLEAR", newSViv(XCB_GX_CLEAR));
    newCONSTSUB(stash, "GX_AND", newSViv(XCB_GX_AND));
    newCONSTSUB(stash, "GX_AND_REVERSE", newSViv(XCB_GX_AND_REVERSE));
    newCONSTSUB(stash, "GX_COPY", newSViv(XCB_GX_COPY));
    newCONSTSUB(stash, "GX_AND_INVERTED", newSViv(XCB_GX_AND_INVERTED));
    newCONSTSUB(stash, "GX_NOOP", newSViv(XCB_GX_NOOP));
    newCONSTSUB(stash, "GX_XOR", newSViv(XCB_GX_XOR));
    newCONSTSUB(stash, "GX_OR", newSViv(XCB_GX_OR));
    newCONSTSUB(stash, "GX_NOR", newSViv(XCB_GX_NOR));
    newCONSTSUB(stash, "GX_EQUIV", newSViv(XCB_GX_EQUIV));
    newCONSTSUB(stash, "GX_INVERT", newSViv(XCB_GX_INVERT));
    newCONSTSUB(stash, "GX_OR_REVERSE", newSViv(XCB_GX_OR_REVERSE));
    newCONSTSUB(stash, "GX_COPY_INVERTED", newSViv(XCB_GX_COPY_INVERTED));
    newCONSTSUB(stash, "GX_OR_INVERTED", newSViv(XCB_GX_OR_INVERTED));
    newCONSTSUB(stash, "GX_NAND", newSViv(XCB_GX_NAND));
    newCONSTSUB(stash, "GX_SET", newSViv(XCB_GX_SET));
    newCONSTSUB(stash, "LINE_STYLE_SOLID", newSViv(XCB_LINE_STYLE_SOLID));
    newCONSTSUB(stash, "LINE_STYLE_ON_OFF_DASH", newSViv(XCB_LINE_STYLE_ON_OFF_DASH));
    newCONSTSUB(stash, "LINE_STYLE_DOUBLE_DASH", newSViv(XCB_LINE_STYLE_DOUBLE_DASH));
    newCONSTSUB(stash, "CAP_STYLE_NOT_LAST", newSViv(XCB_CAP_STYLE_NOT_LAST));
    newCONSTSUB(stash, "CAP_STYLE_BUTT", newSViv(XCB_CAP_STYLE_BUTT));
    newCONSTSUB(stash, "CAP_STYLE_ROUND", newSViv(XCB_CAP_STYLE_ROUND));
    newCONSTSUB(stash, "CAP_STYLE_PROJECTING", newSViv(XCB_CAP_STYLE_PROJECTING));
    newCONSTSUB(stash, "JOIN_STYLE_MITRE", newSViv(XCB_JOIN_STYLE_MITRE));
    newCONSTSUB(stash, "JOIN_STYLE_ROUND", newSViv(XCB_JOIN_STYLE_ROUND));
    newCONSTSUB(stash, "JOIN_STYLE_BEVEL", newSViv(XCB_JOIN_STYLE_BEVEL));
    newCONSTSUB(stash, "FILL_STYLE_SOLID", newSViv(XCB_FILL_STYLE_SOLID));
    newCONSTSUB(stash, "FILL_STYLE_TILED", newSViv(XCB_FILL_STYLE_TILED));
    newCONSTSUB(stash, "FILL_STYLE_STIPPLED", newSViv(XCB_FILL_STYLE_STIPPLED));
    newCONSTSUB(stash, "FILL_STYLE_OPAQUE_STIPPLED", newSViv(XCB_FILL_STYLE_OPAQUE_STIPPLED));
    newCONSTSUB(stash, "FILL_RULE_EVEN_ODD", newSViv(XCB_FILL_RULE_EVEN_ODD));
    newCONSTSUB(stash, "FILL_RULE_WINDING", newSViv(XCB_FILL_RULE_WINDING));
    newCONSTSUB(stash, "SUBWINDOW_MODE_CLIP_BY_CHILDREN", newSViv(XCB_SUBWINDOW_MODE_CLIP_BY_CHILDREN));
    newCONSTSUB(stash, "SUBWINDOW_MODE_INCLUDE_INFERIORS", newSViv(XCB_SUBWINDOW_MODE_INCLUDE_INFERIORS));
    newCONSTSUB(stash, "ARC_MODE_CHORD", newSViv(XCB_ARC_MODE_CHORD));
    newCONSTSUB(stash, "ARC_MODE_PIE_SLICE", newSViv(XCB_ARC_MODE_PIE_SLICE));
    newCONSTSUB(stash, "CLIP_ORDERING_UNSORTED", newSViv(XCB_CLIP_ORDERING_UNSORTED));
    newCONSTSUB(stash, "CLIP_ORDERING_Y_SORTED", newSViv(XCB_CLIP_ORDERING_Y_SORTED));
    newCONSTSUB(stash, "CLIP_ORDERING_YX_SORTED", newSViv(XCB_CLIP_ORDERING_YX_SORTED));
    newCONSTSUB(stash, "CLIP_ORDERING_YX_BANDED", newSViv(XCB_CLIP_ORDERING_YX_BANDED));
    newCONSTSUB(stash, "COORD_MODE_ORIGIN", newSViv(XCB_COORD_MODE_ORIGIN));
    newCONSTSUB(stash, "COORD_MODE_PREVIOUS", newSViv(XCB_COORD_MODE_PREVIOUS));
    newCONSTSUB(stash, "POLY_SHAPE_COMPLEX", newSViv(XCB_POLY_SHAPE_COMPLEX));
    newCONSTSUB(stash, "POLY_SHAPE_NONCONVEX", newSViv(XCB_POLY_SHAPE_NONCONVEX));
    newCONSTSUB(stash, "POLY_SHAPE_CONVEX", newSViv(XCB_POLY_SHAPE_CONVEX));
    newCONSTSUB(stash, "IMAGE_FORMAT_XY_BITMAP", newSViv(XCB_IMAGE_FORMAT_XY_BITMAP));
    newCONSTSUB(stash, "IMAGE_FORMAT_XY_PIXMAP", newSViv(XCB_IMAGE_FORMAT_XY_PIXMAP));
    newCONSTSUB(stash, "IMAGE_FORMAT_Z_PIXMAP", newSViv(XCB_IMAGE_FORMAT_Z_PIXMAP));
    newCONSTSUB(stash, "COLORMAP_ALLOC_NONE", newSViv(XCB_COLORMAP_ALLOC_NONE));
    newCONSTSUB(stash, "COLORMAP_ALLOC_ALL", newSViv(XCB_COLORMAP_ALLOC_ALL));
    newCONSTSUB(stash, "COLOR_FLAG_RED", newSViv(XCB_COLOR_FLAG_RED));
    newCONSTSUB(stash, "COLOR_FLAG_GREEN", newSViv(XCB_COLOR_FLAG_GREEN));
    newCONSTSUB(stash, "COLOR_FLAG_BLUE", newSViv(XCB_COLOR_FLAG_BLUE));
    newCONSTSUB(stash, "QUERY_SHAPE_OF_LARGEST_CURSOR", newSViv(XCB_QUERY_SHAPE_OF_LARGEST_CURSOR));
    newCONSTSUB(stash, "QUERY_SHAPE_OF_FASTEST_TILE", newSViv(XCB_QUERY_SHAPE_OF_FASTEST_TILE));
    newCONSTSUB(stash, "QUERY_SHAPE_OF_FASTEST_STIPPLE", newSViv(XCB_QUERY_SHAPE_OF_FASTEST_STIPPLE));
    newCONSTSUB(stash, "KB_KEY_CLICK_PERCENT", newSViv(XCB_KB_KEY_CLICK_PERCENT));
    newCONSTSUB(stash, "KB_BELL_PERCENT", newSViv(XCB_KB_BELL_PERCENT));
    newCONSTSUB(stash, "KB_BELL_PITCH", newSViv(XCB_KB_BELL_PITCH));
    newCONSTSUB(stash, "KB_BELL_DURATION", newSViv(XCB_KB_BELL_DURATION));
    newCONSTSUB(stash, "KB_LED", newSViv(XCB_KB_LED));
    newCONSTSUB(stash, "KB_LED_MODE", newSViv(XCB_KB_LED_MODE));
    newCONSTSUB(stash, "KB_KEY", newSViv(XCB_KB_KEY));
    newCONSTSUB(stash, "KB_AUTO_REPEAT_MODE", newSViv(XCB_KB_AUTO_REPEAT_MODE));
    newCONSTSUB(stash, "LED_MODE_OFF", newSViv(XCB_LED_MODE_OFF));
    newCONSTSUB(stash, "LED_MODE_ON", newSViv(XCB_LED_MODE_ON));
    newCONSTSUB(stash, "AUTO_REPEAT_MODE_OFF", newSViv(XCB_AUTO_REPEAT_MODE_OFF));
    newCONSTSUB(stash, "AUTO_REPEAT_MODE_ON", newSViv(XCB_AUTO_REPEAT_MODE_ON));
    newCONSTSUB(stash, "AUTO_REPEAT_MODE_DEFAULT", newSViv(XCB_AUTO_REPEAT_MODE_DEFAULT));
    newCONSTSUB(stash, "BLANKING_NOT_PREFERRED", newSViv(XCB_BLANKING_NOT_PREFERRED));
    newCONSTSUB(stash, "BLANKING_PREFERRED", newSViv(XCB_BLANKING_PREFERRED));
    newCONSTSUB(stash, "BLANKING_DEFAULT", newSViv(XCB_BLANKING_DEFAULT));
    newCONSTSUB(stash, "EXPOSURES_NOT_ALLOWED", newSViv(XCB_EXPOSURES_NOT_ALLOWED));
    newCONSTSUB(stash, "EXPOSURES_ALLOWED", newSViv(XCB_EXPOSURES_ALLOWED));
    newCONSTSUB(stash, "EXPOSURES_DEFAULT", newSViv(XCB_EXPOSURES_DEFAULT));
    newCONSTSUB(stash, "HOST_MODE_INSERT", newSViv(XCB_HOST_MODE_INSERT));
    newCONSTSUB(stash, "HOST_MODE_DELETE", newSViv(XCB_HOST_MODE_DELETE));
    newCONSTSUB(stash, "FAMILY_INTERNET", newSViv(XCB_FAMILY_INTERNET));
    newCONSTSUB(stash, "FAMILY_DECNET", newSViv(XCB_FAMILY_DECNET));
    newCONSTSUB(stash, "FAMILY_CHAOS", newSViv(XCB_FAMILY_CHAOS));
    newCONSTSUB(stash, "FAMILY_SERVER_INTERPRETED", newSViv(XCB_FAMILY_SERVER_INTERPRETED));
    newCONSTSUB(stash, "FAMILY_INTERNET_6", newSViv(XCB_FAMILY_INTERNET_6));
    newCONSTSUB(stash, "ACCESS_CONTROL_DISABLE", newSViv(XCB_ACCESS_CONTROL_DISABLE));
    newCONSTSUB(stash, "ACCESS_CONTROL_ENABLE", newSViv(XCB_ACCESS_CONTROL_ENABLE));
    newCONSTSUB(stash, "CLOSE_DOWN_DESTROY_ALL", newSViv(XCB_CLOSE_DOWN_DESTROY_ALL));
    newCONSTSUB(stash, "CLOSE_DOWN_RETAIN_PERMANENT", newSViv(XCB_CLOSE_DOWN_RETAIN_PERMANENT));
    newCONSTSUB(stash, "CLOSE_DOWN_RETAIN_TEMPORARY", newSViv(XCB_CLOSE_DOWN_RETAIN_TEMPORARY));
    newCONSTSUB(stash, "KILL_ALL_TEMPORARY", newSViv(XCB_KILL_ALL_TEMPORARY));
    newCONSTSUB(stash, "SCREEN_SAVER_RESET", newSViv(XCB_SCREEN_SAVER_RESET));
    newCONSTSUB(stash, "SCREEN_SAVER_ACTIVE", newSViv(XCB_SCREEN_SAVER_ACTIVE));
    newCONSTSUB(stash, "MAPPING_STATUS_SUCCESS", newSViv(XCB_MAPPING_STATUS_SUCCESS));
    newCONSTSUB(stash, "MAPPING_STATUS_BUSY", newSViv(XCB_MAPPING_STATUS_BUSY));
    newCONSTSUB(stash, "MAPPING_STATUS_FAILURE", newSViv(XCB_MAPPING_STATUS_FAILURE));
    newCONSTSUB(stash, "MAP_INDEX_SHIFT", newSViv(XCB_MAP_INDEX_SHIFT));
    newCONSTSUB(stash, "MAP_INDEX_LOCK", newSViv(XCB_MAP_INDEX_LOCK));
    newCONSTSUB(stash, "MAP_INDEX_CONTROL", newSViv(XCB_MAP_INDEX_CONTROL));
    newCONSTSUB(stash, "MAP_INDEX_1", newSViv(XCB_MAP_INDEX_1));
    newCONSTSUB(stash, "MAP_INDEX_2", newSViv(XCB_MAP_INDEX_2));
    newCONSTSUB(stash, "MAP_INDEX_3", newSViv(XCB_MAP_INDEX_3));
    newCONSTSUB(stash, "MAP_INDEX_4", newSViv(XCB_MAP_INDEX_4));
    newCONSTSUB(stash, "MAP_INDEX_5", newSViv(XCB_MAP_INDEX_5));
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


MODULE = X11::XCB PACKAGE = XCBChar2b
XCBChar2b *
new(self,byte1,byte2)
    char *self
    int byte1
    int byte2
  PREINIT:
    XCBChar2b *buf;
  CODE:
    New(0, buf, 1, XCBChar2b);
    buf->byte1 = byte1;
    buf->byte2 = byte2;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBChar2bPtr

int
byte1(self)
    XCBChar2b * self
  CODE:
    RETVAL = self->byte1;
  OUTPUT:
    RETVAL

int
byte2(self)
    XCBChar2b * self
  CODE:
    RETVAL = self->byte2;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBPoint
XCBPoint *
new(self,x,y)
    char *self
    int x
    int y
  PREINIT:
    XCBPoint *buf;
  CODE:
    New(0, buf, 1, XCBPoint);
    buf->x = x;
    buf->y = y;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBPointPtr

int
x(self)
    XCBPoint * self
  CODE:
    RETVAL = self->x;
  OUTPUT:
    RETVAL

int
y(self)
    XCBPoint * self
  CODE:
    RETVAL = self->y;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBRectangle
XCBRectangle *
new(self,x,y,width,height)
    char *self
    int x
    int y
    int width
    int height
  PREINIT:
    XCBRectangle *buf;
  CODE:
    New(0, buf, 1, XCBRectangle);
    buf->x = x;
    buf->y = y;
    buf->width = width;
    buf->height = height;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBRectanglePtr

int
x(self)
    XCBRectangle * self
  CODE:
    RETVAL = self->x;
  OUTPUT:
    RETVAL

int
y(self)
    XCBRectangle * self
  CODE:
    RETVAL = self->y;
  OUTPUT:
    RETVAL

int
width(self)
    XCBRectangle * self
  CODE:
    RETVAL = self->width;
  OUTPUT:
    RETVAL

int
height(self)
    XCBRectangle * self
  CODE:
    RETVAL = self->height;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBArc
XCBArc *
new(self,x,y,width,height,angle1,angle2)
    char *self
    int x
    int y
    int width
    int height
    int angle1
    int angle2
  PREINIT:
    XCBArc *buf;
  CODE:
    New(0, buf, 1, XCBArc);
    buf->x = x;
    buf->y = y;
    buf->width = width;
    buf->height = height;
    buf->angle1 = angle1;
    buf->angle2 = angle2;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBArcPtr

int
x(self)
    XCBArc * self
  CODE:
    RETVAL = self->x;
  OUTPUT:
    RETVAL

int
y(self)
    XCBArc * self
  CODE:
    RETVAL = self->y;
  OUTPUT:
    RETVAL

int
width(self)
    XCBArc * self
  CODE:
    RETVAL = self->width;
  OUTPUT:
    RETVAL

int
height(self)
    XCBArc * self
  CODE:
    RETVAL = self->height;
  OUTPUT:
    RETVAL

int
angle1(self)
    XCBArc * self
  CODE:
    RETVAL = self->angle1;
  OUTPUT:
    RETVAL

int
angle2(self)
    XCBArc * self
  CODE:
    RETVAL = self->angle2;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBFormat
XCBFormat *
new(self,depth,bits_per_pixel,scanline_pad)
    char *self
    int depth
    int bits_per_pixel
    int scanline_pad
  PREINIT:
    XCBFormat *buf;
  CODE:
    New(0, buf, 1, XCBFormat);
    buf->depth = depth;
    buf->bits_per_pixel = bits_per_pixel;
    buf->scanline_pad = scanline_pad;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBFormatPtr

int
depth(self)
    XCBFormat * self
  CODE:
    RETVAL = self->depth;
  OUTPUT:
    RETVAL

int
bits_per_pixel(self)
    XCBFormat * self
  CODE:
    RETVAL = self->bits_per_pixel;
  OUTPUT:
    RETVAL

int
scanline_pad(self)
    XCBFormat * self
  CODE:
    RETVAL = self->scanline_pad;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBVisualtype
XCBVisualtype *
new(self,visual_id,class,bits_per_rgb_value,colormap_entries,red_mask,green_mask,blue_mask)
    char *self
    int visual_id
    int class
    int bits_per_rgb_value
    int colormap_entries
    int red_mask
    int green_mask
    int blue_mask
  PREINIT:
    XCBVisualtype *buf;
  CODE:
    New(0, buf, 1, XCBVisualtype);
    buf->visual_id = visual_id;
    buf->_class = class;
    buf->bits_per_rgb_value = bits_per_rgb_value;
    buf->colormap_entries = colormap_entries;
    buf->red_mask = red_mask;
    buf->green_mask = green_mask;
    buf->blue_mask = blue_mask;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBVisualtypePtr

int
visual_id(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->visual_id;
  OUTPUT:
    RETVAL

int
class(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->_class;
  OUTPUT:
    RETVAL

int
bits_per_rgb_value(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->bits_per_rgb_value;
  OUTPUT:
    RETVAL

int
colormap_entries(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->colormap_entries;
  OUTPUT:
    RETVAL

int
red_mask(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->red_mask;
  OUTPUT:
    RETVAL

int
green_mask(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->green_mask;
  OUTPUT:
    RETVAL

int
blue_mask(self)
    XCBVisualtype * self
  CODE:
    RETVAL = self->blue_mask;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBDepth
XCBDepth *
new(self,depth,visuals_len)
    char *self
    int depth
    int visuals_len
  PREINIT:
    XCBDepth *buf;
  CODE:
    New(0, buf, 1, XCBDepth);
    buf->depth = depth;
    buf->visuals_len = visuals_len;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBScreen
XCBScreen *
new(self,root,default_colormap,white_pixel,black_pixel,current_input_masks,width_in_pixels,height_in_pixels,width_in_millimeters,height_in_millimeters,min_installed_maps,max_installed_maps,root_visual,backing_stores,save_unders,root_depth,allowed_depths_len)
    char *self
    int root
    int default_colormap
    int white_pixel
    int black_pixel
    int current_input_masks
    int width_in_pixels
    int height_in_pixels
    int width_in_millimeters
    int height_in_millimeters
    int min_installed_maps
    int max_installed_maps
    int root_visual
    int backing_stores
    int save_unders
    int root_depth
    int allowed_depths_len
  PREINIT:
    XCBScreen *buf;
  CODE:
    New(0, buf, 1, XCBScreen);
    buf->root = root;
    buf->default_colormap = default_colormap;
    buf->white_pixel = white_pixel;
    buf->black_pixel = black_pixel;
    buf->current_input_masks = current_input_masks;
    buf->width_in_pixels = width_in_pixels;
    buf->height_in_pixels = height_in_pixels;
    buf->width_in_millimeters = width_in_millimeters;
    buf->height_in_millimeters = height_in_millimeters;
    buf->min_installed_maps = min_installed_maps;
    buf->max_installed_maps = max_installed_maps;
    buf->root_visual = root_visual;
    buf->backing_stores = backing_stores;
    buf->save_unders = save_unders;
    buf->root_depth = root_depth;
    buf->allowed_depths_len = allowed_depths_len;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBSetup_request
XCBSetup_request *
new(self,byte_order,protocol_major_version,protocol_minor_version,authorization_protocol_name_len,authorization_protocol_data_len)
    char *self
    int byte_order
    int protocol_major_version
    int protocol_minor_version
    int authorization_protocol_name_len
    int authorization_protocol_data_len
  PREINIT:
    XCBSetup_request *buf;
  CODE:
    New(0, buf, 1, XCBSetup_request);
    buf->byte_order = byte_order;
    buf->protocol_major_version = protocol_major_version;
    buf->protocol_minor_version = protocol_minor_version;
    buf->authorization_protocol_name_len = authorization_protocol_name_len;
    buf->authorization_protocol_data_len = authorization_protocol_data_len;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBSetup_failed
XCBSetup_failed *
new(self,status,reason_len,protocol_major_version,protocol_minor_version,length)
    char *self
    int status
    int reason_len
    int protocol_major_version
    int protocol_minor_version
    int length
  PREINIT:
    XCBSetup_failed *buf;
  CODE:
    New(0, buf, 1, XCBSetup_failed);
    buf->status = status;
    buf->reason_len = reason_len;
    buf->protocol_major_version = protocol_major_version;
    buf->protocol_minor_version = protocol_minor_version;
    buf->length = length;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBSetup_authenticate
XCBSetup_authenticate *
new(self,status,length)
    char *self
    int status
    int length
  PREINIT:
    XCBSetup_authenticate *buf;
  CODE:
    New(0, buf, 1, XCBSetup_authenticate);
    buf->status = status;
    buf->length = length;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBSetup
XCBSetup *
new(self,status,protocol_major_version,protocol_minor_version,length,release_number,resource_id_base,resource_id_mask,motion_buffer_size,vendor_len,maximum_request_length,roots_len,pixmap_formats_len,image_byte_order,bitmap_format_bit_order,bitmap_format_scanline_unit,bitmap_format_scanline_pad,min_keycode,max_keycode)
    char *self
    int status
    int protocol_major_version
    int protocol_minor_version
    int length
    int release_number
    int resource_id_base
    int resource_id_mask
    int motion_buffer_size
    int vendor_len
    int maximum_request_length
    int roots_len
    int pixmap_formats_len
    int image_byte_order
    int bitmap_format_bit_order
    int bitmap_format_scanline_unit
    int bitmap_format_scanline_pad
    int min_keycode
    int max_keycode
  PREINIT:
    XCBSetup *buf;
  CODE:
    New(0, buf, 1, XCBSetup);
    buf->status = status;
    buf->protocol_major_version = protocol_major_version;
    buf->protocol_minor_version = protocol_minor_version;
    buf->length = length;
    buf->release_number = release_number;
    buf->resource_id_base = resource_id_base;
    buf->resource_id_mask = resource_id_mask;
    buf->motion_buffer_size = motion_buffer_size;
    buf->vendor_len = vendor_len;
    buf->maximum_request_length = maximum_request_length;
    buf->roots_len = roots_len;
    buf->pixmap_formats_len = pixmap_formats_len;
    buf->image_byte_order = image_byte_order;
    buf->bitmap_format_bit_order = bitmap_format_bit_order;
    buf->bitmap_format_scanline_unit = bitmap_format_scanline_unit;
    buf->bitmap_format_scanline_pad = bitmap_format_scanline_pad;
    buf->min_keycode = min_keycode;
    buf->max_keycode = max_keycode;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBTimecoord
XCBTimecoord *
new(self,time,x,y)
    char *self
    int time
    int x
    int y
  PREINIT:
    XCBTimecoord *buf;
  CODE:
    New(0, buf, 1, XCBTimecoord);
    buf->time = time;
    buf->x = x;
    buf->y = y;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBTimecoordPtr

int
time(self)
    XCBTimecoord * self
  CODE:
    RETVAL = self->time;
  OUTPUT:
    RETVAL

int
x(self)
    XCBTimecoord * self
  CODE:
    RETVAL = self->x;
  OUTPUT:
    RETVAL

int
y(self)
    XCBTimecoord * self
  CODE:
    RETVAL = self->y;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBFontprop
XCBFontprop *
new(self,name,value)
    char *self
    int name
    int value
  PREINIT:
    XCBFontprop *buf;
  CODE:
    New(0, buf, 1, XCBFontprop);
    buf->name = name;
    buf->value = value;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBFontpropPtr

int
name(self)
    XCBFontprop * self
  CODE:
    RETVAL = self->name;
  OUTPUT:
    RETVAL

int
value(self)
    XCBFontprop * self
  CODE:
    RETVAL = self->value;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBCharinfo
XCBCharinfo *
new(self,left_side_bearing,right_side_bearing,character_width,ascent,descent,attributes)
    char *self
    int left_side_bearing
    int right_side_bearing
    int character_width
    int ascent
    int descent
    int attributes
  PREINIT:
    XCBCharinfo *buf;
  CODE:
    New(0, buf, 1, XCBCharinfo);
    buf->left_side_bearing = left_side_bearing;
    buf->right_side_bearing = right_side_bearing;
    buf->character_width = character_width;
    buf->ascent = ascent;
    buf->descent = descent;
    buf->attributes = attributes;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBCharinfoPtr

int
left_side_bearing(self)
    XCBCharinfo * self
  CODE:
    RETVAL = self->left_side_bearing;
  OUTPUT:
    RETVAL

int
right_side_bearing(self)
    XCBCharinfo * self
  CODE:
    RETVAL = self->right_side_bearing;
  OUTPUT:
    RETVAL

int
character_width(self)
    XCBCharinfo * self
  CODE:
    RETVAL = self->character_width;
  OUTPUT:
    RETVAL

int
ascent(self)
    XCBCharinfo * self
  CODE:
    RETVAL = self->ascent;
  OUTPUT:
    RETVAL

int
descent(self)
    XCBCharinfo * self
  CODE:
    RETVAL = self->descent;
  OUTPUT:
    RETVAL

int
attributes(self)
    XCBCharinfo * self
  CODE:
    RETVAL = self->attributes;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBStr
XCBStr *
new(self,name_len)
    char *self
    int name_len
  PREINIT:
    XCBStr *buf;
  CODE:
    New(0, buf, 1, XCBStr);
    buf->name_len = name_len;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBSegment
XCBSegment *
new(self,x1,y1,x2,y2)
    char *self
    int x1
    int y1
    int x2
    int y2
  PREINIT:
    XCBSegment *buf;
  CODE:
    New(0, buf, 1, XCBSegment);
    buf->x1 = x1;
    buf->y1 = y1;
    buf->x2 = x2;
    buf->y2 = y2;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBSegmentPtr

int
x1(self)
    XCBSegment * self
  CODE:
    RETVAL = self->x1;
  OUTPUT:
    RETVAL

int
y1(self)
    XCBSegment * self
  CODE:
    RETVAL = self->y1;
  OUTPUT:
    RETVAL

int
x2(self)
    XCBSegment * self
  CODE:
    RETVAL = self->x2;
  OUTPUT:
    RETVAL

int
y2(self)
    XCBSegment * self
  CODE:
    RETVAL = self->y2;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBColoritem
XCBColoritem *
new(self,pixel,red,green,blue,flags)
    char *self
    int pixel
    int red
    int green
    int blue
    int flags
  PREINIT:
    XCBColoritem *buf;
  CODE:
    New(0, buf, 1, XCBColoritem);
    buf->pixel = pixel;
    buf->red = red;
    buf->green = green;
    buf->blue = blue;
    buf->flags = flags;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBColoritemPtr

int
pixel(self)
    XCBColoritem * self
  CODE:
    RETVAL = self->pixel;
  OUTPUT:
    RETVAL

int
red(self)
    XCBColoritem * self
  CODE:
    RETVAL = self->red;
  OUTPUT:
    RETVAL

int
green(self)
    XCBColoritem * self
  CODE:
    RETVAL = self->green;
  OUTPUT:
    RETVAL

int
blue(self)
    XCBColoritem * self
  CODE:
    RETVAL = self->blue;
  OUTPUT:
    RETVAL

int
flags(self)
    XCBColoritem * self
  CODE:
    RETVAL = self->flags;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBRgb
XCBRgb *
new(self,red,green,blue)
    char *self
    int red
    int green
    int blue
  PREINIT:
    XCBRgb *buf;
  CODE:
    New(0, buf, 1, XCBRgb);
    buf->red = red;
    buf->green = green;
    buf->blue = blue;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBRgbPtr

int
red(self)
    XCBRgb * self
  CODE:
    RETVAL = self->red;
  OUTPUT:
    RETVAL

int
green(self)
    XCBRgb * self
  CODE:
    RETVAL = self->green;
  OUTPUT:
    RETVAL

int
blue(self)
    XCBRgb * self
  CODE:
    RETVAL = self->blue;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBHost
XCBHost *
new(self,family,address_len)
    char *self
    int family
    int address_len
  PREINIT:
    XCBHost *buf;
  CODE:
    New(0, buf, 1, XCBHost);
    buf->family = family;
    buf->address_len = address_len;
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = XCBConnectionPtr
HV *
create_window(conn,depth,wid,parent,x,y,width,height,border_width,class,visual,value_mask,value_list,...)
    XCBConnection *conn
    int depth
    int wid
    int parent
    int x
    int y
    int width
    int height
    int border_width
    int class
    int visual
    int value_mask
    intArray *value_list

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_create_window(conn->conn, depth, wid, parent, x, y, width, height, border_width, class, visual, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

HV *
change_window_attributes(conn,window,value_mask,value_list,...)
    XCBConnection *conn
    int window
    int value_mask
    intArray *value_list

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_window_attributes(conn->conn, window, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

HV *
get_window_attributes(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_get_window_attributes_cookie_t cookie;
  CODE:
    cookie = xcb_get_window_attributes(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
destroy_window(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_destroy_window(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
destroy_subwindows(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_destroy_subwindows(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_save_set(conn,mode,window)
    XCBConnection *conn
    int mode
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_save_set(conn->conn, mode, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
reparent_window(conn,window,parent,x,y)
    XCBConnection *conn
    int window
    int parent
    int x
    int y

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_reparent_window(conn->conn, window, parent, x, y);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
map_window(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_map_window(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
map_subwindows(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_map_subwindows(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
unmap_window(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_unmap_window(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
unmap_subwindows(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_unmap_subwindows(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
configure_window(conn,window,value_mask,value_list,...)
    XCBConnection *conn
    int window
    int value_mask
    intArray *value_list

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_configure_window(conn->conn, window, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

HV *
circulate_window(conn,direction,window)
    XCBConnection *conn
    int direction
    int window

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_circulate_window(conn->conn, direction, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_geometry(conn,drawable)
    XCBConnection *conn
    int drawable

  PREINIT:
    HV * hash;
    xcb_get_geometry_cookie_t cookie;
  CODE:
    cookie = xcb_get_geometry(conn->conn, drawable);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_tree(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_query_tree_cookie_t cookie;
  CODE:
    cookie = xcb_query_tree(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
intern_atom(conn,only_if_exists,name_len,name)
    XCBConnection *conn
    int only_if_exists
    int name_len
    char *name

  PREINIT:
    HV * hash;
    xcb_intern_atom_cookie_t cookie;
  CODE:
    cookie = xcb_intern_atom(conn->conn, only_if_exists, name_len, name);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_atom_name(conn,atom)
    XCBConnection *conn
    int atom

  PREINIT:
    HV * hash;
    xcb_get_atom_name_cookie_t cookie;
  CODE:
    cookie = xcb_get_atom_name(conn->conn, atom);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_property(conn,mode,window,property,type,format,data_len,data)
    XCBConnection *conn
    int mode
    int window
    int property
    int type
    int format
    int data_len
    void *data

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_property(conn->conn, mode, window, property, type, format, data_len, data);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
delete_property(conn,window,property)
    XCBConnection *conn
    int window
    int property

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_delete_property(conn->conn, window, property);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_property(conn,delete,window,property,type,long_offset,long_length)
    XCBConnection *conn
    int delete
    int window
    int property
    int type
    int long_offset
    int long_length

  PREINIT:
    HV * hash;
    xcb_get_property_cookie_t cookie;
  CODE:
    cookie = xcb_get_property(conn->conn, delete, window, property, type, long_offset, long_length);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_properties(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_list_properties_cookie_t cookie;
  CODE:
    cookie = xcb_list_properties(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_selection_owner(conn,owner,selection,time)
    XCBConnection *conn
    int owner
    int selection
    int time

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_selection_owner(conn->conn, owner, selection, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_selection_owner(conn,selection)
    XCBConnection *conn
    int selection

  PREINIT:
    HV * hash;
    xcb_get_selection_owner_cookie_t cookie;
  CODE:
    cookie = xcb_get_selection_owner(conn->conn, selection);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
convert_selection(conn,requestor,selection,target,property,time)
    XCBConnection *conn
    int requestor
    int selection
    int target
    int property
    int time

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_convert_selection(conn->conn, requestor, selection, target, property, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
send_event(conn,propagate,destination,event_mask,event)
    XCBConnection *conn
    int propagate
    int destination
    int event_mask
    char *event

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_send_event(conn->conn, propagate, destination, event_mask, event);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_pointer(conn,owner_events,grab_window,event_mask,pointer_mode,keyboard_mode,confine_to,cursor,time)
    XCBConnection *conn
    int owner_events
    int grab_window
    int event_mask
    int pointer_mode
    int keyboard_mode
    int confine_to
    int cursor
    int time

  PREINIT:
    HV * hash;
    xcb_grab_pointer_cookie_t cookie;
  CODE:
    cookie = xcb_grab_pointer(conn->conn, owner_events, grab_window, event_mask, pointer_mode, keyboard_mode, confine_to, cursor, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
ungrab_pointer(conn,time)
    XCBConnection *conn
    int time

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_ungrab_pointer(conn->conn, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_button(conn,owner_events,grab_window,event_mask,pointer_mode,keyboard_mode,confine_to,cursor,button,modifiers)
    XCBConnection *conn
    int owner_events
    int grab_window
    int event_mask
    int pointer_mode
    int keyboard_mode
    int confine_to
    int cursor
    int button
    int modifiers

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_grab_button(conn->conn, owner_events, grab_window, event_mask, pointer_mode, keyboard_mode, confine_to, cursor, button, modifiers);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
ungrab_button(conn,button,grab_window,modifiers)
    XCBConnection *conn
    int button
    int grab_window
    int modifiers

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_ungrab_button(conn->conn, button, grab_window, modifiers);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_active_pointer_grab(conn,cursor,time,event_mask)
    XCBConnection *conn
    int cursor
    int time
    int event_mask

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_active_pointer_grab(conn->conn, cursor, time, event_mask);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_keyboard(conn,owner_events,grab_window,time,pointer_mode,keyboard_mode)
    XCBConnection *conn
    int owner_events
    int grab_window
    int time
    int pointer_mode
    int keyboard_mode

  PREINIT:
    HV * hash;
    xcb_grab_keyboard_cookie_t cookie;
  CODE:
    cookie = xcb_grab_keyboard(conn->conn, owner_events, grab_window, time, pointer_mode, keyboard_mode);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
ungrab_keyboard(conn,time)
    XCBConnection *conn
    int time

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_ungrab_keyboard(conn->conn, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_key(conn,owner_events,grab_window,modifiers,key,pointer_mode,keyboard_mode)
    XCBConnection *conn
    int owner_events
    int grab_window
    int modifiers
    int key
    int pointer_mode
    int keyboard_mode

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_grab_key(conn->conn, owner_events, grab_window, modifiers, key, pointer_mode, keyboard_mode);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
ungrab_key(conn,key,grab_window,modifiers)
    XCBConnection *conn
    int key
    int grab_window
    int modifiers

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_ungrab_key(conn->conn, key, grab_window, modifiers);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
allow_events(conn,mode,time)
    XCBConnection *conn
    int mode
    int time

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_allow_events(conn->conn, mode, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_server(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_grab_server(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
ungrab_server(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_ungrab_server(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_pointer(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_query_pointer_cookie_t cookie;
  CODE:
    cookie = xcb_query_pointer(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_motion_events(conn,window,start,stop)
    XCBConnection *conn
    int window
    int start
    int stop

  PREINIT:
    HV * hash;
    xcb_get_motion_events_cookie_t cookie;
  CODE:
    cookie = xcb_get_motion_events(conn->conn, window, start, stop);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
translate_coordinates(conn,src_window,dst_window,src_x,src_y)
    XCBConnection *conn
    int src_window
    int dst_window
    int src_x
    int src_y

  PREINIT:
    HV * hash;
    xcb_translate_coordinates_cookie_t cookie;
  CODE:
    cookie = xcb_translate_coordinates(conn->conn, src_window, dst_window, src_x, src_y);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
warp_pointer(conn,src_window,dst_window,src_x,src_y,src_width,src_height,dst_x,dst_y)
    XCBConnection *conn
    int src_window
    int dst_window
    int src_x
    int src_y
    int src_width
    int src_height
    int dst_x
    int dst_y

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_warp_pointer(conn->conn, src_window, dst_window, src_x, src_y, src_width, src_height, dst_x, dst_y);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_input_focus(conn,revert_to,focus,time)
    XCBConnection *conn
    int revert_to
    int focus
    int time

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_input_focus(conn->conn, revert_to, focus, time);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_input_focus(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_input_focus_cookie_t cookie;
  CODE:
    cookie = xcb_get_input_focus(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_keymap(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_query_keymap_cookie_t cookie;
  CODE:
    cookie = xcb_query_keymap(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
open_font(conn,fid,name_len,name)
    XCBConnection *conn
    int fid
    int name_len
    char *name

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_open_font(conn->conn, fid, name_len, name);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
close_font(conn,font)
    XCBConnection *conn
    int font

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_close_font(conn->conn, font);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_font(conn,font)
    XCBConnection *conn
    int font

  PREINIT:
    HV * hash;
    xcb_query_font_cookie_t cookie;
  CODE:
    cookie = xcb_query_font(conn->conn, font);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_text_extents(conn,font,string_len,string)
    XCBConnection *conn
    int font
    int string_len
    XCBChar2b *string

  PREINIT:
    HV * hash;
    xcb_query_text_extents_cookie_t cookie;
  CODE:
    cookie = xcb_query_text_extents(conn->conn, font, string_len, string);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(string);
  OUTPUT:
    RETVAL

HV *
list_fonts(conn,max_names,pattern_len,pattern)
    XCBConnection *conn
    int max_names
    int pattern_len
    char *pattern

  PREINIT:
    HV * hash;
    xcb_list_fonts_cookie_t cookie;
  CODE:
    cookie = xcb_list_fonts(conn->conn, max_names, pattern_len, pattern);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_fonts_with_info(conn,max_names,pattern_len,pattern)
    XCBConnection *conn
    int max_names
    int pattern_len
    char *pattern

  PREINIT:
    HV * hash;
    xcb_list_fonts_with_info_cookie_t cookie;
  CODE:
    cookie = xcb_list_fonts_with_info(conn->conn, max_names, pattern_len, pattern);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_font_path(conn,font_qty,path_len,path)
    XCBConnection *conn
    int font_qty
    int path_len
    char *path

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_font_path(conn->conn, font_qty, path_len, path);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_font_path(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_font_path_cookie_t cookie;
  CODE:
    cookie = xcb_get_font_path(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
create_pixmap(conn,depth,pid,drawable,width,height)
    XCBConnection *conn
    int depth
    int pid
    int drawable
    int width
    int height

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_create_pixmap(conn->conn, depth, pid, drawable, width, height);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
free_pixmap(conn,pixmap)
    XCBConnection *conn
    int pixmap

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_free_pixmap(conn->conn, pixmap);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
create_gc(conn,cid,drawable,value_mask,value_list,...)
    XCBConnection *conn
    int cid
    int drawable
    int value_mask
    intArray *value_list

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_create_gc(conn->conn, cid, drawable, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

HV *
change_gc(conn,gc,value_mask,value_list,...)
    XCBConnection *conn
    int gc
    int value_mask
    intArray *value_list

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_gc(conn->conn, gc, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

HV *
copy_gc(conn,src_gc,dst_gc,value_mask)
    XCBConnection *conn
    int src_gc
    int dst_gc
    int value_mask

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_copy_gc(conn->conn, src_gc, dst_gc, value_mask);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_dashes(conn,gc,dash_offset,dashes_len,dashes)
    XCBConnection *conn
    int gc
    int dash_offset
    int dashes_len
    intArray *dashes

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_dashes(conn->conn, gc, dash_offset, dashes_len, dashes);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(dashes);
  OUTPUT:
    RETVAL

HV *
set_clip_rectangles(conn,ordering,gc,clip_x_origin,clip_y_origin,rectangles_len,rectangles)
    XCBConnection *conn
    int ordering
    int gc
    int clip_x_origin
    int clip_y_origin
    int rectangles_len
    XCBRectangle *rectangles

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_clip_rectangles(conn->conn, ordering, gc, clip_x_origin, clip_y_origin, rectangles_len, rectangles);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(rectangles);
  OUTPUT:
    RETVAL

HV *
free_gc(conn,gc)
    XCBConnection *conn
    int gc

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_free_gc(conn->conn, gc);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
clear_area(conn,exposures,window,x,y,width,height)
    XCBConnection *conn
    int exposures
    int window
    int x
    int y
    int width
    int height

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_clear_area(conn->conn, exposures, window, x, y, width, height);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
copy_area(conn,src_drawable,dst_drawable,gc,src_x,src_y,dst_x,dst_y,width,height)
    XCBConnection *conn
    int src_drawable
    int dst_drawable
    int gc
    int src_x
    int src_y
    int dst_x
    int dst_y
    int width
    int height

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_copy_area(conn->conn, src_drawable, dst_drawable, gc, src_x, src_y, dst_x, dst_y, width, height);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
copy_plane(conn,src_drawable,dst_drawable,gc,src_x,src_y,dst_x,dst_y,width,height,bit_plane)
    XCBConnection *conn
    int src_drawable
    int dst_drawable
    int gc
    int src_x
    int src_y
    int dst_x
    int dst_y
    int width
    int height
    int bit_plane

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_copy_plane(conn->conn, src_drawable, dst_drawable, gc, src_x, src_y, dst_x, dst_y, width, height, bit_plane);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
poly_point(conn,coordinate_mode,drawable,gc,points_len,points)
    XCBConnection *conn
    int coordinate_mode
    int drawable
    int gc
    int points_len
    XCBPoint *points

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_point(conn->conn, coordinate_mode, drawable, gc, points_len, points);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(points);
  OUTPUT:
    RETVAL

HV *
poly_line(conn,coordinate_mode,drawable,gc,points_len,points)
    XCBConnection *conn
    int coordinate_mode
    int drawable
    int gc
    int points_len
    XCBPoint *points

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_line(conn->conn, coordinate_mode, drawable, gc, points_len, points);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(points);
  OUTPUT:
    RETVAL

HV *
poly_segment(conn,drawable,gc,segments_len,segments)
    XCBConnection *conn
    int drawable
    int gc
    int segments_len
    XCBSegment *segments

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_segment(conn->conn, drawable, gc, segments_len, segments);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(segments);
  OUTPUT:
    RETVAL

HV *
poly_rectangle(conn,drawable,gc,rectangles_len,rectangles)
    XCBConnection *conn
    int drawable
    int gc
    int rectangles_len
    XCBRectangle *rectangles

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_rectangle(conn->conn, drawable, gc, rectangles_len, rectangles);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(rectangles);
  OUTPUT:
    RETVAL

HV *
poly_arc(conn,drawable,gc,arcs_len,arcs)
    XCBConnection *conn
    int drawable
    int gc
    int arcs_len
    XCBArc *arcs

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_arc(conn->conn, drawable, gc, arcs_len, arcs);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(arcs);
  OUTPUT:
    RETVAL

HV *
fill_poly(conn,drawable,gc,shape,coordinate_mode,points_len,points)
    XCBConnection *conn
    int drawable
    int gc
    int shape
    int coordinate_mode
    int points_len
    XCBPoint *points

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_fill_poly(conn->conn, drawable, gc, shape, coordinate_mode, points_len, points);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(points);
  OUTPUT:
    RETVAL

HV *
poly_fill_rectangle(conn,drawable,gc,rectangles_len,rectangles)
    XCBConnection *conn
    int drawable
    int gc
    int rectangles_len
    XCBRectangle *rectangles

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_fill_rectangle(conn->conn, drawable, gc, rectangles_len, rectangles);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(rectangles);
  OUTPUT:
    RETVAL

HV *
poly_fill_arc(conn,drawable,gc,arcs_len,arcs)
    XCBConnection *conn
    int drawable
    int gc
    int arcs_len
    XCBArc *arcs

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_fill_arc(conn->conn, drawable, gc, arcs_len, arcs);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(arcs);
  OUTPUT:
    RETVAL

HV *
put_image(conn,format,drawable,gc,width,height,dst_x,dst_y,left_pad,depth,data_len,data)
    XCBConnection *conn
    int format
    int drawable
    int gc
    int width
    int height
    int dst_x
    int dst_y
    int left_pad
    int depth
    int data_len
    intArray *data

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_put_image(conn->conn, format, drawable, gc, width, height, dst_x, dst_y, left_pad, depth, data_len, data);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(data);
  OUTPUT:
    RETVAL

HV *
get_image(conn,format,drawable,x,y,width,height,plane_mask)
    XCBConnection *conn
    int format
    int drawable
    int x
    int y
    int width
    int height
    int plane_mask

  PREINIT:
    HV * hash;
    xcb_get_image_cookie_t cookie;
  CODE:
    cookie = xcb_get_image(conn->conn, format, drawable, x, y, width, height, plane_mask);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
poly_text_8(conn,drawable,gc,x,y,items_len,items)
    XCBConnection *conn
    int drawable
    int gc
    int x
    int y
    int items_len
    intArray *items

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_text_8(conn->conn, drawable, gc, x, y, items_len, items);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(items);
  OUTPUT:
    RETVAL

HV *
poly_text_16(conn,drawable,gc,x,y,items_len,items)
    XCBConnection *conn
    int drawable
    int gc
    int x
    int y
    int items_len
    intArray *items

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_poly_text_16(conn->conn, drawable, gc, x, y, items_len, items);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(items);
  OUTPUT:
    RETVAL

HV *
image_text_8(conn,string_len,drawable,gc,x,y,string)
    XCBConnection *conn
    int string_len
    int drawable
    int gc
    int x
    int y
    char *string

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_image_text_8(conn->conn, string_len, drawable, gc, x, y, string);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
image_text_16(conn,string_len,drawable,gc,x,y,string)
    XCBConnection *conn
    int string_len
    int drawable
    int gc
    int x
    int y
    XCBChar2b *string

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_image_text_16(conn->conn, string_len, drawable, gc, x, y, string);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(string);
  OUTPUT:
    RETVAL

HV *
create_colormap(conn,alloc,mid,window,visual)
    XCBConnection *conn
    int alloc
    int mid
    int window
    int visual

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_create_colormap(conn->conn, alloc, mid, window, visual);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
free_colormap(conn,cmap)
    XCBConnection *conn
    int cmap

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_free_colormap(conn->conn, cmap);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
copy_colormap_and_free(conn,mid,src_cmap)
    XCBConnection *conn
    int mid
    int src_cmap

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_copy_colormap_and_free(conn->conn, mid, src_cmap);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
install_colormap(conn,cmap)
    XCBConnection *conn
    int cmap

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_install_colormap(conn->conn, cmap);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
uninstall_colormap(conn,cmap)
    XCBConnection *conn
    int cmap

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_uninstall_colormap(conn->conn, cmap);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_installed_colormaps(conn,window)
    XCBConnection *conn
    int window

  PREINIT:
    HV * hash;
    xcb_list_installed_colormaps_cookie_t cookie;
  CODE:
    cookie = xcb_list_installed_colormaps(conn->conn, window);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_color(conn,cmap,red,green,blue)
    XCBConnection *conn
    int cmap
    int red
    int green
    int blue

  PREINIT:
    HV * hash;
    xcb_alloc_color_cookie_t cookie;
  CODE:
    cookie = xcb_alloc_color(conn->conn, cmap, red, green, blue);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_named_color(conn,cmap,name_len,name)
    XCBConnection *conn
    int cmap
    int name_len
    char *name

  PREINIT:
    HV * hash;
    xcb_alloc_named_color_cookie_t cookie;
  CODE:
    cookie = xcb_alloc_named_color(conn->conn, cmap, name_len, name);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_color_cells(conn,contiguous,cmap,colors,planes)
    XCBConnection *conn
    int contiguous
    int cmap
    int colors
    int planes

  PREINIT:
    HV * hash;
    xcb_alloc_color_cells_cookie_t cookie;
  CODE:
    cookie = xcb_alloc_color_cells(conn->conn, contiguous, cmap, colors, planes);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_color_planes(conn,contiguous,cmap,colors,reds,greens,blues)
    XCBConnection *conn
    int contiguous
    int cmap
    int colors
    int reds
    int greens
    int blues

  PREINIT:
    HV * hash;
    xcb_alloc_color_planes_cookie_t cookie;
  CODE:
    cookie = xcb_alloc_color_planes(conn->conn, contiguous, cmap, colors, reds, greens, blues);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
free_colors(conn,cmap,plane_mask,pixels_len,pixels)
    XCBConnection *conn
    int cmap
    int plane_mask
    int pixels_len
    intArray *pixels

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_free_colors(conn->conn, cmap, plane_mask, pixels_len, pixels);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(pixels);
  OUTPUT:
    RETVAL

HV *
store_colors(conn,cmap,items_len,items)
    XCBConnection *conn
    int cmap
    int items_len
    XCBColoritem *items

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_store_colors(conn->conn, cmap, items_len, items);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(items);
  OUTPUT:
    RETVAL

HV *
store_named_color(conn,flags,cmap,pixel,name_len,name)
    XCBConnection *conn
    int flags
    int cmap
    int pixel
    int name_len
    char *name

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_store_named_color(conn->conn, flags, cmap, pixel, name_len, name);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_colors(conn,cmap,pixels_len,pixels)
    XCBConnection *conn
    int cmap
    int pixels_len
    intArray *pixels

  PREINIT:
    HV * hash;
    xcb_query_colors_cookie_t cookie;
  CODE:
    cookie = xcb_query_colors(conn->conn, cmap, pixels_len, pixels);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(pixels);
  OUTPUT:
    RETVAL

HV *
lookup_color(conn,cmap,name_len,name)
    XCBConnection *conn
    int cmap
    int name_len
    char *name

  PREINIT:
    HV * hash;
    xcb_lookup_color_cookie_t cookie;
  CODE:
    cookie = xcb_lookup_color(conn->conn, cmap, name_len, name);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
create_cursor(conn,cid,source,mask,fore_red,fore_green,fore_blue,back_red,back_green,back_blue,x,y)
    XCBConnection *conn
    int cid
    int source
    int mask
    int fore_red
    int fore_green
    int fore_blue
    int back_red
    int back_green
    int back_blue
    int x
    int y

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_create_cursor(conn->conn, cid, source, mask, fore_red, fore_green, fore_blue, back_red, back_green, back_blue, x, y);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
create_glyph_cursor(conn,cid,source_font,mask_font,source_char,mask_char,fore_red,fore_green,fore_blue,back_red,back_green,back_blue)
    XCBConnection *conn
    int cid
    int source_font
    int mask_font
    int source_char
    int mask_char
    int fore_red
    int fore_green
    int fore_blue
    int back_red
    int back_green
    int back_blue

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_create_glyph_cursor(conn->conn, cid, source_font, mask_font, source_char, mask_char, fore_red, fore_green, fore_blue, back_red, back_green, back_blue);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
free_cursor(conn,cursor)
    XCBConnection *conn
    int cursor

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_free_cursor(conn->conn, cursor);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
recolor_cursor(conn,cursor,fore_red,fore_green,fore_blue,back_red,back_green,back_blue)
    XCBConnection *conn
    int cursor
    int fore_red
    int fore_green
    int fore_blue
    int back_red
    int back_green
    int back_blue

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_recolor_cursor(conn->conn, cursor, fore_red, fore_green, fore_blue, back_red, back_green, back_blue);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_best_size(conn,class,drawable,width,height)
    XCBConnection *conn
    int class
    int drawable
    int width
    int height

  PREINIT:
    HV * hash;
    xcb_query_best_size_cookie_t cookie;
  CODE:
    cookie = xcb_query_best_size(conn->conn, class, drawable, width, height);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_extension(conn,name_len,name)
    XCBConnection *conn
    int name_len
    char *name

  PREINIT:
    HV * hash;
    xcb_query_extension_cookie_t cookie;
  CODE:
    cookie = xcb_query_extension(conn->conn, name_len, name);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_extensions(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_list_extensions_cookie_t cookie;
  CODE:
    cookie = xcb_list_extensions(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_keyboard_mapping(conn,keycode_count,first_keycode,keysyms_per_keycode,keysyms)
    XCBConnection *conn
    int keycode_count
    int first_keycode
    int keysyms_per_keycode
    intArray *keysyms

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_keyboard_mapping(conn->conn, keycode_count, first_keycode, keysyms_per_keycode, keysyms);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(keysyms);
  OUTPUT:
    RETVAL

HV *
get_keyboard_mapping(conn,first_keycode,count)
    XCBConnection *conn
    int first_keycode
    int count

  PREINIT:
    HV * hash;
    xcb_get_keyboard_mapping_cookie_t cookie;
  CODE:
    cookie = xcb_get_keyboard_mapping(conn->conn, first_keycode, count);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_keyboard_control(conn,value_mask,value_list,...)
    XCBConnection *conn
    int value_mask
    intArray *value_list

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_keyboard_control(conn->conn, value_mask, value_list);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(value_list);
  OUTPUT:
    RETVAL

HV *
get_keyboard_control(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_keyboard_control_cookie_t cookie;
  CODE:
    cookie = xcb_get_keyboard_control(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
bell(conn,percent)
    XCBConnection *conn
    int percent

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_bell(conn->conn, percent);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_pointer_control(conn,acceleration_numerator,acceleration_denominator,threshold,do_acceleration,do_threshold)
    XCBConnection *conn
    int acceleration_numerator
    int acceleration_denominator
    int threshold
    int do_acceleration
    int do_threshold

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_pointer_control(conn->conn, acceleration_numerator, acceleration_denominator, threshold, do_acceleration, do_threshold);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_pointer_control(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_pointer_control_cookie_t cookie;
  CODE:
    cookie = xcb_get_pointer_control(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_screen_saver(conn,timeout,interval,prefer_blanking,allow_exposures)
    XCBConnection *conn
    int timeout
    int interval
    int prefer_blanking
    int allow_exposures

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_screen_saver(conn->conn, timeout, interval, prefer_blanking, allow_exposures);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_screen_saver(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_screen_saver_cookie_t cookie;
  CODE:
    cookie = xcb_get_screen_saver(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
change_hosts(conn,mode,family,address_len,address)
    XCBConnection *conn
    int mode
    int family
    int address_len
    char *address

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_change_hosts(conn->conn, mode, family, address_len, address);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_hosts(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_list_hosts_cookie_t cookie;
  CODE:
    cookie = xcb_list_hosts(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_access_control(conn,mode)
    XCBConnection *conn
    int mode

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_access_control(conn->conn, mode);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_close_down_mode(conn,mode)
    XCBConnection *conn
    int mode

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_set_close_down_mode(conn->conn, mode);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
kill_client(conn,resource)
    XCBConnection *conn
    int resource

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_kill_client(conn->conn, resource);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
rotate_properties(conn,window,atoms_len,delta,atoms)
    XCBConnection *conn
    int window
    int atoms_len
    int delta
    intArray *atoms

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_rotate_properties(conn->conn, window, atoms_len, delta, atoms);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(atoms);
  OUTPUT:
    RETVAL

HV *
force_screen_saver(conn,mode)
    XCBConnection *conn
    int mode

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_force_screen_saver(conn->conn, mode);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_pointer_mapping(conn,map_len,map)
    XCBConnection *conn
    int map_len
    intArray *map

  PREINIT:
    HV * hash;
    xcb_set_pointer_mapping_cookie_t cookie;
  CODE:
    cookie = xcb_set_pointer_mapping(conn->conn, map_len, map);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(map);
  OUTPUT:
    RETVAL

HV *
get_pointer_mapping(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_pointer_mapping_cookie_t cookie;
  CODE:
    cookie = xcb_get_pointer_mapping(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_modifier_mapping(conn,keycodes_per_modifier,keycodes)
    XCBConnection *conn
    int keycodes_per_modifier
    intArray *keycodes

  PREINIT:
    HV * hash;
    xcb_set_modifier_mapping_cookie_t cookie;
  CODE:
    cookie = xcb_set_modifier_mapping(conn->conn, keycodes_per_modifier, keycodes);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
    free(keycodes);
  OUTPUT:
    RETVAL

HV *
get_modifier_mapping(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_get_modifier_mapping_cookie_t cookie;
  CODE:
    cookie = xcb_get_modifier_mapping(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
no_operation(conn)
    XCBConnection *conn

  PREINIT:
    HV * hash;
    xcb_void_cookie_t cookie;
  CODE:
    xcb_no_operation(conn->conn);

    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(cookie.sequence), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_window_attributes_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_window_attributes_cookie_t cookie;
    xcb_get_window_attributes_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_window_attributes_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "backing_store", strlen("backing_store"), newSViv(reply->backing_store), 0);
    hv_store(hash, "visual", strlen("visual"), newSViv(reply->visual), 0);
    hv_store(hash, "_class", strlen("_class"), newSViv(reply->_class), 0);
    hv_store(hash, "bit_gravity", strlen("bit_gravity"), newSViv(reply->bit_gravity), 0);
    hv_store(hash, "win_gravity", strlen("win_gravity"), newSViv(reply->win_gravity), 0);
    hv_store(hash, "backing_planes", strlen("backing_planes"), newSViv(reply->backing_planes), 0);
    hv_store(hash, "backing_pixel", strlen("backing_pixel"), newSViv(reply->backing_pixel), 0);
    hv_store(hash, "save_under", strlen("save_under"), newSViv(reply->save_under), 0);
    hv_store(hash, "map_is_installed", strlen("map_is_installed"), newSViv(reply->map_is_installed), 0);
    hv_store(hash, "map_state", strlen("map_state"), newSViv(reply->map_state), 0);
    hv_store(hash, "override_redirect", strlen("override_redirect"), newSViv(reply->override_redirect), 0);
    hv_store(hash, "colormap", strlen("colormap"), newSViv(reply->colormap), 0);
    hv_store(hash, "all_event_masks", strlen("all_event_masks"), newSViv(reply->all_event_masks), 0);
    hv_store(hash, "your_event_mask", strlen("your_event_mask"), newSViv(reply->your_event_mask), 0);
    hv_store(hash, "do_not_propagate_mask", strlen("do_not_propagate_mask"), newSViv(reply->do_not_propagate_mask), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_geometry_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_geometry_cookie_t cookie;
    xcb_get_geometry_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_geometry_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "depth", strlen("depth"), newSViv(reply->depth), 0);
    hv_store(hash, "root", strlen("root"), newSViv(reply->root), 0);
    hv_store(hash, "x", strlen("x"), newSViv(reply->x), 0);
    hv_store(hash, "y", strlen("y"), newSViv(reply->y), 0);
    hv_store(hash, "width", strlen("width"), newSViv(reply->width), 0);
    hv_store(hash, "height", strlen("height"), newSViv(reply->height), 0);
    hv_store(hash, "border_width", strlen("border_width"), newSViv(reply->border_width), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_tree_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_tree_cookie_t cookie;
    xcb_query_tree_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_tree_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "root", strlen("root"), newSViv(reply->root), 0);
    hv_store(hash, "parent", strlen("parent"), newSViv(reply->parent), 0);
    hv_store(hash, "children_len", strlen("children_len"), newSViv(reply->children_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
intern_atom_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_intern_atom_cookie_t cookie;
    xcb_intern_atom_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_intern_atom_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "atom", strlen("atom"), newSViv(reply->atom), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_atom_name_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_atom_name_cookie_t cookie;
    xcb_get_atom_name_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_atom_name_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "name_len", strlen("name_len"), newSViv(reply->name_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_property_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_property_cookie_t cookie;
    xcb_get_property_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_property_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "format", strlen("format"), newSViv(reply->format), 0);
    hv_store(hash, "type", strlen("type"), newSViv(reply->type), 0);
    hv_store(hash, "bytes_after", strlen("bytes_after"), newSViv(reply->bytes_after), 0);
    hv_store(hash, "value_len", strlen("value_len"), newSViv(reply->value_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_properties_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_list_properties_cookie_t cookie;
    xcb_list_properties_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_list_properties_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "atoms_len", strlen("atoms_len"), newSViv(reply->atoms_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_selection_owner_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_selection_owner_cookie_t cookie;
    xcb_get_selection_owner_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_selection_owner_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "owner", strlen("owner"), newSViv(reply->owner), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_pointer_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_grab_pointer_cookie_t cookie;
    xcb_grab_pointer_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_grab_pointer_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "status", strlen("status"), newSViv(reply->status), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
grab_keyboard_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_grab_keyboard_cookie_t cookie;
    xcb_grab_keyboard_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_grab_keyboard_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "status", strlen("status"), newSViv(reply->status), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_pointer_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_pointer_cookie_t cookie;
    xcb_query_pointer_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_pointer_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "same_screen", strlen("same_screen"), newSViv(reply->same_screen), 0);
    hv_store(hash, "root", strlen("root"), newSViv(reply->root), 0);
    hv_store(hash, "child", strlen("child"), newSViv(reply->child), 0);
    hv_store(hash, "root_x", strlen("root_x"), newSViv(reply->root_x), 0);
    hv_store(hash, "root_y", strlen("root_y"), newSViv(reply->root_y), 0);
    hv_store(hash, "win_x", strlen("win_x"), newSViv(reply->win_x), 0);
    hv_store(hash, "win_y", strlen("win_y"), newSViv(reply->win_y), 0);
    hv_store(hash, "mask", strlen("mask"), newSViv(reply->mask), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_motion_events_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_motion_events_cookie_t cookie;
    xcb_get_motion_events_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_motion_events_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "events_len", strlen("events_len"), newSViv(reply->events_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
translate_coordinates_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_translate_coordinates_cookie_t cookie;
    xcb_translate_coordinates_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_translate_coordinates_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "same_screen", strlen("same_screen"), newSViv(reply->same_screen), 0);
    hv_store(hash, "child", strlen("child"), newSViv(reply->child), 0);
    hv_store(hash, "dst_x", strlen("dst_x"), newSViv(reply->dst_x), 0);
    hv_store(hash, "dst_y", strlen("dst_y"), newSViv(reply->dst_y), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_input_focus_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_input_focus_cookie_t cookie;
    xcb_get_input_focus_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_input_focus_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "revert_to", strlen("revert_to"), newSViv(reply->revert_to), 0);
    hv_store(hash, "focus", strlen("focus"), newSViv(reply->focus), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_keymap_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_keymap_cookie_t cookie;
    xcb_query_keymap_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_keymap_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_font_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_font_cookie_t cookie;
    xcb_query_font_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_font_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    /* TODO: type xcb_charinfo_t, name min_bounds */
    /* TODO: type xcb_charinfo_t, name max_bounds */
    hv_store(hash, "min_char_or_byte2", strlen("min_char_or_byte2"), newSViv(reply->min_char_or_byte2), 0);
    hv_store(hash, "max_char_or_byte2", strlen("max_char_or_byte2"), newSViv(reply->max_char_or_byte2), 0);
    hv_store(hash, "default_char", strlen("default_char"), newSViv(reply->default_char), 0);
    hv_store(hash, "properties_len", strlen("properties_len"), newSViv(reply->properties_len), 0);
    hv_store(hash, "draw_direction", strlen("draw_direction"), newSViv(reply->draw_direction), 0);
    hv_store(hash, "min_byte1", strlen("min_byte1"), newSViv(reply->min_byte1), 0);
    hv_store(hash, "max_byte1", strlen("max_byte1"), newSViv(reply->max_byte1), 0);
    hv_store(hash, "all_chars_exist", strlen("all_chars_exist"), newSViv(reply->all_chars_exist), 0);
    hv_store(hash, "font_ascent", strlen("font_ascent"), newSViv(reply->font_ascent), 0);
    hv_store(hash, "font_descent", strlen("font_descent"), newSViv(reply->font_descent), 0);
    hv_store(hash, "char_infos_len", strlen("char_infos_len"), newSViv(reply->char_infos_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_text_extents_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_text_extents_cookie_t cookie;
    xcb_query_text_extents_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_text_extents_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "draw_direction", strlen("draw_direction"), newSViv(reply->draw_direction), 0);
    hv_store(hash, "font_ascent", strlen("font_ascent"), newSViv(reply->font_ascent), 0);
    hv_store(hash, "font_descent", strlen("font_descent"), newSViv(reply->font_descent), 0);
    hv_store(hash, "overall_ascent", strlen("overall_ascent"), newSViv(reply->overall_ascent), 0);
    hv_store(hash, "overall_descent", strlen("overall_descent"), newSViv(reply->overall_descent), 0);
    hv_store(hash, "overall_width", strlen("overall_width"), newSViv(reply->overall_width), 0);
    hv_store(hash, "overall_left", strlen("overall_left"), newSViv(reply->overall_left), 0);
    hv_store(hash, "overall_right", strlen("overall_right"), newSViv(reply->overall_right), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_fonts_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_list_fonts_cookie_t cookie;
    xcb_list_fonts_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_list_fonts_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "names_len", strlen("names_len"), newSViv(reply->names_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_fonts_with_info_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_list_fonts_with_info_cookie_t cookie;
    xcb_list_fonts_with_info_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_list_fonts_with_info_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "name_len", strlen("name_len"), newSViv(reply->name_len), 0);
    /* TODO: type xcb_charinfo_t, name min_bounds */
    /* TODO: type xcb_charinfo_t, name max_bounds */
    hv_store(hash, "min_char_or_byte2", strlen("min_char_or_byte2"), newSViv(reply->min_char_or_byte2), 0);
    hv_store(hash, "max_char_or_byte2", strlen("max_char_or_byte2"), newSViv(reply->max_char_or_byte2), 0);
    hv_store(hash, "default_char", strlen("default_char"), newSViv(reply->default_char), 0);
    hv_store(hash, "properties_len", strlen("properties_len"), newSViv(reply->properties_len), 0);
    hv_store(hash, "draw_direction", strlen("draw_direction"), newSViv(reply->draw_direction), 0);
    hv_store(hash, "min_byte1", strlen("min_byte1"), newSViv(reply->min_byte1), 0);
    hv_store(hash, "max_byte1", strlen("max_byte1"), newSViv(reply->max_byte1), 0);
    hv_store(hash, "all_chars_exist", strlen("all_chars_exist"), newSViv(reply->all_chars_exist), 0);
    hv_store(hash, "font_ascent", strlen("font_ascent"), newSViv(reply->font_ascent), 0);
    hv_store(hash, "font_descent", strlen("font_descent"), newSViv(reply->font_descent), 0);
    hv_store(hash, "replies_hint", strlen("replies_hint"), newSViv(reply->replies_hint), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_font_path_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_font_path_cookie_t cookie;
    xcb_get_font_path_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_font_path_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "path_len", strlen("path_len"), newSViv(reply->path_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_image_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_image_cookie_t cookie;
    xcb_get_image_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_image_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "depth", strlen("depth"), newSViv(reply->depth), 0);
    hv_store(hash, "visual", strlen("visual"), newSViv(reply->visual), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_installed_colormaps_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_list_installed_colormaps_cookie_t cookie;
    xcb_list_installed_colormaps_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_list_installed_colormaps_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "cmaps_len", strlen("cmaps_len"), newSViv(reply->cmaps_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_color_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_alloc_color_cookie_t cookie;
    xcb_alloc_color_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_alloc_color_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "red", strlen("red"), newSViv(reply->red), 0);
    hv_store(hash, "green", strlen("green"), newSViv(reply->green), 0);
    hv_store(hash, "blue", strlen("blue"), newSViv(reply->blue), 0);
    hv_store(hash, "pixel", strlen("pixel"), newSViv(reply->pixel), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_named_color_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_alloc_named_color_cookie_t cookie;
    xcb_alloc_named_color_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_alloc_named_color_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "pixel", strlen("pixel"), newSViv(reply->pixel), 0);
    hv_store(hash, "exact_red", strlen("exact_red"), newSViv(reply->exact_red), 0);
    hv_store(hash, "exact_green", strlen("exact_green"), newSViv(reply->exact_green), 0);
    hv_store(hash, "exact_blue", strlen("exact_blue"), newSViv(reply->exact_blue), 0);
    hv_store(hash, "visual_red", strlen("visual_red"), newSViv(reply->visual_red), 0);
    hv_store(hash, "visual_green", strlen("visual_green"), newSViv(reply->visual_green), 0);
    hv_store(hash, "visual_blue", strlen("visual_blue"), newSViv(reply->visual_blue), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_color_cells_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_alloc_color_cells_cookie_t cookie;
    xcb_alloc_color_cells_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_alloc_color_cells_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "pixels_len", strlen("pixels_len"), newSViv(reply->pixels_len), 0);
    hv_store(hash, "masks_len", strlen("masks_len"), newSViv(reply->masks_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
alloc_color_planes_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_alloc_color_planes_cookie_t cookie;
    xcb_alloc_color_planes_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_alloc_color_planes_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "pixels_len", strlen("pixels_len"), newSViv(reply->pixels_len), 0);
    hv_store(hash, "red_mask", strlen("red_mask"), newSViv(reply->red_mask), 0);
    hv_store(hash, "green_mask", strlen("green_mask"), newSViv(reply->green_mask), 0);
    hv_store(hash, "blue_mask", strlen("blue_mask"), newSViv(reply->blue_mask), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_colors_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_colors_cookie_t cookie;
    xcb_query_colors_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_colors_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "colors_len", strlen("colors_len"), newSViv(reply->colors_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
lookup_color_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_lookup_color_cookie_t cookie;
    xcb_lookup_color_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_lookup_color_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "exact_red", strlen("exact_red"), newSViv(reply->exact_red), 0);
    hv_store(hash, "exact_green", strlen("exact_green"), newSViv(reply->exact_green), 0);
    hv_store(hash, "exact_blue", strlen("exact_blue"), newSViv(reply->exact_blue), 0);
    hv_store(hash, "visual_red", strlen("visual_red"), newSViv(reply->visual_red), 0);
    hv_store(hash, "visual_green", strlen("visual_green"), newSViv(reply->visual_green), 0);
    hv_store(hash, "visual_blue", strlen("visual_blue"), newSViv(reply->visual_blue), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_best_size_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_best_size_cookie_t cookie;
    xcb_query_best_size_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_best_size_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "width", strlen("width"), newSViv(reply->width), 0);
    hv_store(hash, "height", strlen("height"), newSViv(reply->height), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
query_extension_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_query_extension_cookie_t cookie;
    xcb_query_extension_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_query_extension_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "present", strlen("present"), newSViv(reply->present), 0);
    hv_store(hash, "major_opcode", strlen("major_opcode"), newSViv(reply->major_opcode), 0);
    hv_store(hash, "first_event", strlen("first_event"), newSViv(reply->first_event), 0);
    hv_store(hash, "first_error", strlen("first_error"), newSViv(reply->first_error), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_extensions_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_list_extensions_cookie_t cookie;
    xcb_list_extensions_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_list_extensions_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "names_len", strlen("names_len"), newSViv(reply->names_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_keyboard_mapping_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_keyboard_mapping_cookie_t cookie;
    xcb_get_keyboard_mapping_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_keyboard_mapping_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "keysyms_per_keycode", strlen("keysyms_per_keycode"), newSViv(reply->keysyms_per_keycode), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_keyboard_control_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_keyboard_control_cookie_t cookie;
    xcb_get_keyboard_control_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_keyboard_control_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "global_auto_repeat", strlen("global_auto_repeat"), newSViv(reply->global_auto_repeat), 0);
    hv_store(hash, "led_mask", strlen("led_mask"), newSViv(reply->led_mask), 0);
    hv_store(hash, "key_click_percent", strlen("key_click_percent"), newSViv(reply->key_click_percent), 0);
    hv_store(hash, "bell_percent", strlen("bell_percent"), newSViv(reply->bell_percent), 0);
    hv_store(hash, "bell_pitch", strlen("bell_pitch"), newSViv(reply->bell_pitch), 0);
    hv_store(hash, "bell_duration", strlen("bell_duration"), newSViv(reply->bell_duration), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_pointer_control_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_pointer_control_cookie_t cookie;
    xcb_get_pointer_control_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_pointer_control_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "acceleration_numerator", strlen("acceleration_numerator"), newSViv(reply->acceleration_numerator), 0);
    hv_store(hash, "acceleration_denominator", strlen("acceleration_denominator"), newSViv(reply->acceleration_denominator), 0);
    hv_store(hash, "threshold", strlen("threshold"), newSViv(reply->threshold), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_screen_saver_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_screen_saver_cookie_t cookie;
    xcb_get_screen_saver_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_screen_saver_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "timeout", strlen("timeout"), newSViv(reply->timeout), 0);
    hv_store(hash, "interval", strlen("interval"), newSViv(reply->interval), 0);
    hv_store(hash, "prefer_blanking", strlen("prefer_blanking"), newSViv(reply->prefer_blanking), 0);
    hv_store(hash, "allow_exposures", strlen("allow_exposures"), newSViv(reply->allow_exposures), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
list_hosts_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_list_hosts_cookie_t cookie;
    xcb_list_hosts_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_list_hosts_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "mode", strlen("mode"), newSViv(reply->mode), 0);
    hv_store(hash, "hosts_len", strlen("hosts_len"), newSViv(reply->hosts_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_pointer_mapping_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_set_pointer_mapping_cookie_t cookie;
    xcb_set_pointer_mapping_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_set_pointer_mapping_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "status", strlen("status"), newSViv(reply->status), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_pointer_mapping_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_pointer_mapping_cookie_t cookie;
    xcb_get_pointer_mapping_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_pointer_mapping_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "map_len", strlen("map_len"), newSViv(reply->map_len), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
set_modifier_mapping_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_set_modifier_mapping_cookie_t cookie;
    xcb_set_modifier_mapping_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_set_modifier_mapping_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "status", strlen("status"), newSViv(reply->status), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

HV *
get_modifier_mapping_reply(conn,sequence)
    XCBConnection *conn
    int sequence
  PREINIT:
    HV * hash;
    xcb_get_modifier_mapping_cookie_t cookie;
    xcb_get_modifier_mapping_reply_t *reply;
  CODE:
    cookie.sequence = sequence;
    reply = xcb_get_modifier_mapping_reply(conn->conn, cookie, NULL);
    hash = newHV();
    hv_store(hash, "sequence", strlen("sequence"), newSViv(reply->sequence), 0);
    hv_store(hash, "length", strlen("length"), newSViv(reply->length), 0);
    hv_store(hash, "keycodes_per_modifier", strlen("keycodes_per_modifier"), newSViv(reply->keycodes_per_modifier), 0);
    RETVAL = hash;
  OUTPUT:
    RETVAL

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

