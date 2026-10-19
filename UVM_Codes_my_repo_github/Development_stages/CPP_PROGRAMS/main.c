#include <X11/Xlib.h>
#include <X11/cursorfont.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    Display *dpy;
    Window win;
    XEvent ev;
    Cursor default_cursor, click_cursor;

    // 1. Open connection to the X server (provided automatically by WSLg)
    dpy = XOpenDisplay(NULL);
    if (dpy == NULL) {
        fprintf(stderr, "Cannot open display. Make sure WSLg is running.\n");
        exit(1);
    }

    // 2. Create an application window
    int screen = DefaultScreen(dpy);
    win = XCreateSimpleWindow(dpy, RootWindow(dpy, screen), 100, 100, 500, 400, 1,
                              BlackPixel(dpy, screen), WhitePixel(dpy, screen));

    // Name the window
    XStoreName(dpy, win, "1998 Retro Cursor App (WSL Linux)");

    // 3. Define the cursors from the standard X11 cursor font
    default_cursor = XCreateFontCursor(dpy, XC_left_ptr);
    click_cursor = XCreateFontCursor(dpy, XC_crosshair); // Replaces the classic target/cross pointer

    // Set the initial default cursor for our window
    XDefineCursor(dpy, win, default_cursor);

    // 4. Register the events we care about: Mouse clicks and window visibility
    XSelectInput(dpy, win, ExposureMask | ButtonPressMask | ButtonReleaseMask);

    // Map (show) the window on the screen
    XMapWindow(dpy, win);

    // 5. Main execution loop
    while (1) {
        XNextEvent(dpy, &ev);

        if (ev.type == ButtonPress) {
            if (ev.xbutton.button == Button1) { // Left click pressed
                XDefineCursor(dpy, win, click_cursor);
                XFlush(dpy); // Force immediate visual update
            }
        } 
        else if (ev.type == ButtonRelease) {
            if (ev.xbutton.button == Button1) { // Left click released
                XDefineCursor(dpy, win, default_cursor);
                XFlush(dpy); // Force immediate visual update
            }
        }
    }

    // Clean up resources (unreachable in this basic loop but good practice)
    XFreeCursor(dpy, default_cursor);
    XFreeCursor(dpy, click_cursor);
    XCloseDisplay(dpy);
    return 0;
}
