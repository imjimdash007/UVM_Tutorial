#include <X11/Xlib.h>
#include <X11/cursorfont.h>
#include <stdio.h>
#include <stdlib.h>

// 16x16 Bitmap data for the smiley face (1 = colored pixel, 0 = background)
static unsigned char smiley_bits[] = {
   0x00, 0x00, 0xe0, 0x07, 0x18, 0x18, 0x24, 0x24, 
   0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 
   0x52, 0x4a, 0x42, 0x42, 0x24, 0x24, 0x18, 0x18, 
   0xe0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

// 16x16 Transparency mask data (1 = visible, 0 = see-through background)
static unsigned char smiley_mask_bits[] = {
   0x00, 0x00, 0xe0, 0x07, 0xf8, 0x1f, 0xfc, 0x3f, 
   0xfe, 0x7f, 0xfe, 0x7f, 0xfe, 0x7f, 0xfe, 0x7f, 
   0xfe, 0x7f, 0xfe, 0x7f, 0xfc, 0x3f, 0xf8, 0x1f, 
   0xe0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

int main() {
    Display *dpy;
    Window win;
    XEvent ev;
    Cursor default_cursor, click_cursor;
    Pixmap source_pixmap, mask_pixmap;
    XColor fg, bg;

    // Open connection to the X server
    dpy = XOpenDisplay(NULL);
    if (dpy == NULL) {
        fprintf(stderr, "Cannot open display. Make sure WSLg is running.\n");
        exit(1);
    }

    int screen = DefaultScreen(dpy);
    win = XCreateSimpleWindow(dpy, RootWindow(dpy, screen), 100, 100, 500, 400, 1,
                              BlackPixel(dpy, screen), WhitePixel(dpy, screen));

    XStoreName(dpy, win, "1998 Smiley Face Cursor App");

    // Standard arrow cursor for idle state
    default_cursor = XCreateFontCursor(dpy, XC_left_ptr);

    // Create the bitmaps from our binary arrays
    source_pixmap = XCreateBitmapFromData(dpy, win, (char *)smiley_bits, 16, 16);
    mask_pixmap = XCreateBitmapFromData(dpy, win, (char *)smiley_mask_bits, 16, 16);

    // Define colors for the smiley face (Foreground = Yellow, Background = Black)
    fg.red = 65535; fg.green = 65535; fg.blue = 0;     // Yellow
    bg.red = 0;     bg.green = 0;     bg.blue = 0;     // Black

    // Generate the custom smiley cursor (Hotspot coordinates are set to center 8, 8)
    click_cursor = XCreatePixmapCursor(dpy, source_pixmap, mask_pixmap, &fg, &bg, 8, 8);

    // Initial cursor
    XDefineCursor(dpy, win, default_cursor);

    XSelectInput(dpy, win, ExposureMask | ButtonPressMask | ButtonReleaseMask);
    XMapWindow(dpy, win);

    // Event Loop
    while (1) {
        XNextEvent(dpy, &ev);

        if (ev.type == ButtonPress) {
            if (ev.xbutton.button == Button1) { // Left click
                XDefineCursor(dpy, win, click_cursor);
                XFlush(dpy);
            }
        } 
        else if (ev.type == ButtonRelease) {
            if (ev.xbutton.button == Button1) {
                XDefineCursor(dpy, win, default_cursor);
                XFlush(dpy);
            }
        }
    }

    // Free resources
    XFreePixmap(dpy, source_pixmap);
    XFreePixmap(dpy, mask_pixmap);
    XFreeCursor(dpy, default_cursor);
    XFreeCursor(dpy, click_cursor);
    XCloseDisplay(dpy);
    return 0;
}
//gcc main.c -o SmileyCursorApp -lX11
