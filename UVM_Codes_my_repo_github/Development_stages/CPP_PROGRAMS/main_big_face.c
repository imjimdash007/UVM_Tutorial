//sudo apt update && sudo apt install libxcursor-dev libx11-dev -y
#include <X11/Xlib.h>
#include <X11/Xcursor/Xcursor.h>
#include <X11/cursorfont.h>
#include <stdio.h>
#include <stdlib.h>

#define SIZE 32  // Upscaled canvas size for visibility

// Helper function to dynamically draw a 32x32 pixel RGBA face
Cursor create_color_face(Display *dpy, Window win, int face_type) {
    XcursorImage *img = XcursorImageCreate(SIZE, SIZE);
    if (!img) return None;

    img->xhot = SIZE / 2; // Center the click hotspot
    img->yhot = SIZE / 2;

    XcursorPixel *pixels = img->pixels;

    // Define colors using 0xAARRGGBB format (Alpha, Red, Green, Blue)
    XcursorPixel transparent = 0x00000000;
    XcursorPixel black       = 0xFF000000;
    XcursorPixel white       = 0xFFFFFFFF;
    XcursorPixel skin_color  = (face_type == 0) ? 0xFFFFD700 : 0xFFFF4500; // Yellow (Smile) or Red-Orange (Angry)

    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            int idx = y * SIZE + x;
            
            // Calculate distance from center to draw a circular face
            float dx = x - (SIZE / 2.0f);
            float dy = y - (SIZE / 2.0f);
            float dist = dx * dx + dy * dy;

            // 1. Draw Face Outline Base (Radius ~13 pixels)
            if (dist <= 13 * 13) {
                // Eye coordinates
                int is_left_eye  = (x >= 10 && x <= 13 && y >= 10 && y <= 13);
                int is_right_eye = (x >= 19 && x <= 22 && y >= 10 && y <= 13);

                if (is_left_eye || is_right_eye) {
                    pixels[idx] = black; // Black eyes
                } 
                // 2. Draw Angry Brows (Only for face_type == 1)
                else if (face_type == 1 && y >= 7 && y <= 9 && x >= 8 && x <= 24) {
                    // Left slanted eyebrow
                    if (x <= 14 && (x - 7) == (y - 7 || x - 8 == y - 7 || x - 6 == y - 7)) pixels[idx] = black;
                    // Right slanted eyebrow
                    else if (x >= 17 && (24 - x) == (y - 7 || 23 - x == y - 7 || 25 - x == y - 7)) pixels[idx] = black;
                    else pixels[idx] = skin_color;
                }
                // 3. Draw Mouth
                else if (face_type == 0) {
                    // Smiling Mouth (Arc at bottom)
                    if (y >= 18 && y <= 22 && x >= 9 && x <= 23 && (dist >= 9 * 9 && dist <= 11 * 11)) {
                        pixels[idx] = black;
                    } else {
                        pixels[idx] = skin_color;
                    }
                } else {
                    // Angry Frowning Mouth (Inverted Arc at bottom)
                    float frown_dy = y - 24;
                    float frown_dist = dx * dx + frown_dy * frown_dy;
                    if (y >= 18 && y <= 21 && x >= 10 && x <= 22 && (frown_dist >= 6 * 6 && frown_dist <= 8 * 8)) {
                        pixels[idx] = black;
                    } else {
                        pixels[idx] = skin_color;
                    }
                }
            } 
            // Draw a thin black outer border ring for distinct edge sharpness
            else if (dist > 13 * 13 && dist <= 14.5f * 14.5f) {
                pixels[idx] = black;
            } 
            else {
                pixels[idx] = transparent; // Outside space is completely see-through
            }
        }
    }

    Cursor cursor = XcursorImageLoadCursor(dpy, img);
    XcursorImageDestroy(img);
    return cursor;
}

int main() {
    Display *dpy = XOpenDisplay(NULL);
    if (dpy == NULL) {
        fprintf(stderr, "Cannot open display. Make sure WSLg is running.\n");
        exit(1);
    }

    int screen = DefaultScreen(dpy);
    Window win = XCreateSimpleWindow(dpy, RootWindow(dpy, screen), 100, 100, 500, 400, 1,
                                     BlackPixel(dpy, screen), WhitePixel(dpy, screen));

    XStoreName(dpy, win, "Color Smiley/Angry Retro Cursor Pack");

    // Standard arrow pointer fallback
    Cursor default_cursor = XCreateFontCursor(dpy, XC_left_ptr);
    
    // Generate our colored shapes
    Cursor smiley_cursor = create_color_face(dpy, win, 0); // 0 = Yellow Smile
    Cursor angry_cursor  = create_color_face(dpy, win, 1); // 1 = Red Angry Face

    XDefineCursor(dpy, win, default_cursor);
    XSelectInput(dpy, win, ExposureMask | ButtonPressMask | ButtonReleaseMask);
    XMapWindow(dpy, win);

    XEvent ev;
    while (1) {
        XNextEvent(dpy, &ev);

        if (ev.type == ButtonPress) {
            if (ev.xbutton.button == Button1) {        // Left Click -> Smile
                XDefineCursor(dpy, win, smiley_cursor);
            } else if (ev.xbutton.button == Button3) { // Right Click -> Angry Face
                XDefineCursor(dpy, win, angry_cursor);
            }
            XFlush(dpy);
        } 
        else if (ev.type == ButtonRelease) {
            // Revert back to normal pointer on release of either button
            if (ev.xbutton.button == Button1 || ev.xbutton.button == Button3) {
                XDefineCursor(dpy, win, default_cursor);
                XFlush(dpy);
            }
        }
    }

    XFreeCursor(dpy, default_cursor);
    XFreeCursor(dpy, smiley_cursor);
    XFreeCursor(dpy, angry_cursor);
    XCloseDisplay(dpy);
    return 0;
}
//gcc main_big_face.c -o DynamicCursorApp -lX11 -lXcursor
