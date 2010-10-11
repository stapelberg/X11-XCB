/*
 * vim:ft=xs
 */
MODULE = X11::XCB PACKAGE = X11::XCB::ICCCM::WMHints

PROTOTYPES: ENABLE

X11_XCB_ICCCM_WMHints *
new(self)
    char *self
  PREINIT:
    X11_XCB_ICCCM_WMHints *buf;
  CODE:
    New(0, buf, 1, X11_XCB_ICCCM_WMHints);
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = X11_XCB_ICCCM_WMHintsPtr

void
set_urgency(self)
    X11_XCB_ICCCM_WMHints * self
  CODE:
    xcb_wm_hints_set_urgency(self);

MODULE = X11::XCB PACKAGE = X11::XCB::ICCCM

void
set_wm_hints(conn, window, hints)
    XCBConnection * conn
    int window
    X11_XCB_ICCCM_WMHints * hints
  CODE:
    xcb_set_wm_hints(conn->conn, window, hints);

void
set_wm_size_hints(conn, window, property, hints)
    XCBConnection * conn
    int window
    int property
    X11_XCB_ICCCM_SizeHints * hints
  CODE:
    xcb_set_wm_size_hints(conn->conn, window, property, hints);




MODULE = X11::XCB PACKAGE = X11::XCB::ICCCM::SizeHints

PROTOTYPES: ENABLE

X11_XCB_ICCCM_SizeHints *
new(self)
    char *self
  PREINIT:
    X11_XCB_ICCCM_SizeHints *buf;
  CODE:
    New(0, buf, 1, X11_XCB_ICCCM_SizeHints);
    RETVAL = buf;
  OUTPUT:
    RETVAL

MODULE = X11::XCB PACKAGE = X11_XCB_ICCCM_SizeHintsPtr

void
set_aspect(self, min_aspect_num, min_aspect_den, max_aspect_num, max_aspect_den)
    X11_XCB_ICCCM_SizeHints * self
    int min_aspect_num
    int min_aspect_den
    int max_aspect_num
    int max_aspect_den
  CODE:
    xcb_size_hints_set_aspect(self, min_aspect_num, min_aspect_den, max_aspect_num, max_aspect_den);
