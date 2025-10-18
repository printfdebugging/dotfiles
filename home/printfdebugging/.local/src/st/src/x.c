/* See LICENSE for license details. */
#include <errno.h>
#include <math.h>
#include <limits.h>
#include <locale.h>
#include <signal.h>
#include <sys/select.h>
#include <time.h>
#include <unistd.h>
#include <libgen.h>
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <X11/Xft/Xft.h>
#include <X11/XKBlib.h>

char *argv0;
#include "arg.h"
#include "st.h"
#include "win.h"
#include "fonts.h"

/* types used in config.h */
typedef struct {
    uint mod;
    KeySym keysym;
    void (*func)(const Arg *);
    const Arg arg;
} Shortcut;

typedef struct {
    uint mod;
    uint button;
    void (*func)(const Arg *);
    const Arg arg;
    uint release;
} MouseShortcut;

typedef struct {
    KeySym k;
    uint mask;
    char *s;
    /* three-valued logic variables: 0 indifferent, 1 on, -1 off */
    signed char appkey;    /* application keypad */
    signed char appcursor; /* application cursor */
} Key;

/* X modifiers */
#define XK_ANY_MOD    UINT_MAX
#define XK_NO_MOD     0
#define XK_SWITCH_MOD (1 << 13 | 1 << 14)

/* function definitions used in config.h */
static void clipcopy(const Arg *);
static void clippaste(const Arg *);
static void numlock(const Arg *);
static void selpaste(const Arg *);
static void zoom(const Arg *);
static void zoomabs(const Arg *);
static void zoomreset(const Arg *);
static void ttysend(const Arg *);

/* See LICENSE file for copyright and license details. */

/* appearance
 * font: see http://freedesktop.org/software/fontconfig/fontconfig-user.html
 */
static char *font   = "JetBrainsMono Nerd Font:pixelsize=17:style=Regular:antialias=true:autohint=true";
static int borderpx = 4;

/*
 * What program is execed by st depends of these precedence rules:
 * 1: program passed with -e
 * 2: scroll and/or utmp
 * 3: SHELL environment variable
 * 4: value of shell in /etc/passwd
 * 5: value of shell in config.h
 */
static char *shell = "/bin/sh";
char *utmp         = NULL;
/* scroll program: to enable use a string like "scroll" */
char *scroll    = NULL;
char *stty_args = "stty raw pass8 nl -echo -iexten -cstopb 38400";

/* identification sequence returned in DA and DECID */
char *vtiden = "\033[?6c";

/* Kerning / character bounding-box multipliers */
static float cwscale    = 1.0;
static float chscale    = 1.0;
wchar_t *worddelimiters = L" ";

/* selection timeouts (in milliseconds) */
static unsigned int doubleclicktimeout = 300;
static unsigned int tripleclicktimeout = 600;

/* alt screens */
int allowaltscreen = 1;

/* allow certain non-interactive (insecure) window operations such as:
   setting the clipboard text */
int allowwindowops = 0;

/*
 * draw latency range in ms - from new content/keypress/etc until drawing.
 * within this range, st draws when content stops arriving (idle). mostly it's
 * near minlatency, but it waits longer for slow updates to avoid partial draw.
 * low minlatency will tear/flicker more, as it can "detect" idle too early.
 */
static double minlatency = 8;
static double maxlatency = 33;

/*
 * blinking timeout (set to 0 to disable blinking) for the terminal blinking
 * attribute.
 */
static unsigned int blinktimeout = 800;

/*
 * thickness of underline and bar cursors
 */
static unsigned int cursorthickness = 2;

/*
 * 1: render most of the lines/blocks characters without using the font for
 *    perfect alignment between cells (U2500 - U259F except dashes/diagonals).
 *    Bold affects lines thickness if boxdraw_bold is not 0. Italic is ignored.
 * 0: disable (render all U25XX glyphs normally from the font).
 */
const int boxdraw      = 0;
const int boxdraw_bold = 0;

/* braille (U28XX):  1: render as adjacent "pixels",  0: use font */
const int boxdraw_braille = 0;

/*
 * bell volume. It must be a value between -100 and 100. Use 0 for disabling
 * it
 */
static int bellvolume = 0;

/* default TERM value */
char *termname = "st-256color";

/*
 * spaces per tab
 *
 * When you are changing this value, don't forget to adapt the »it« value in
 * the st.info and appropriately install the st.info in the environment where
 * you use this st version.
 *
 *	it#$tabspaces,
 *
 * Secondly make sure your kernel is not expanding tabs. When running `stty
 * -a` »tab0« should appear. You can tell the terminal to not expand tabs by
 *  running following command:
 *
 *	stty tabs
 */
unsigned int tabspaces = 8;

/* bg opacity */
float alpha             = 1.0;
const char *colorname[] = {

    /* 8 normal colors */
    [0] = "#1B2229", /* black   */
    [1] = "#ac4242", /* red     */
    [2] = "#98be65", /* green   */
    [3] = "#f4bf75", /* yellow  */
    [4] = "#51afef", /* blue    */
    [5] = "#aa759f", /* magenta */
    [6] = "#51afef", /* cyan    */
    [7] = "#d8dee9", /* white   */
    /* 8 bright colors */
    [8]  = "#6b6b6b", /* black   */
    [9]  = "#c55555", /* red     */
    [10] = "#98be65", /* green   */
    [11] = "#feca88", /* yellow  */
    [12] = "#51afef", /* blue    */
    [13] = "#c28cb8", /* magenta */
    [14] = "#51afef", /* cyan    */
    [15] = "#d8dee9", /* white   */

    /* special colors */
    [256] = "#282c34", /* background */
    [257] = "#d8dee9", /* foreground */
    [258] = "#51afef", /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */

unsigned int defaultbg  = 256;
unsigned int defaultfg  = 257;
unsigned int defaultcs  = 258;
unsigned int defaultrcs = 258;

/*
 * Default shape of cursor
 * 2: Block ("█")
 * 4: Underline ("_")
 * 6: Bar ("|")
 * 7: Snowman ("☃")
 */
static unsigned int cursorshape = 2;

/*
 * Default columns and rows numbers
 */

static unsigned int cols = 80;
static unsigned int rows = 24;

/*
 * Default colour and shape of the mouse cursor
 */
static unsigned int mouseshape = XC_xterm;
static unsigned int mousefg    = 7;
static unsigned int mousebg    = 0;

/*
 * Color used to display font attributes when fontconfig selected a font which
 * doesn't match the ones requested.
 */
static unsigned int defaultattr = 11;

/*
 * Force mouse select/shortcuts while mask is active (when MODE_MOUSE is set).
 * Note that if you want to use ShiftMask with selmasks, set this to an other
 * modifier, set to 0 to not use it.
 */
static uint forcemousemod = ShiftMask;

/*
 * Internal mouse shortcuts.
 * Beware that overloading Button1 will disable the selection.
 */
/* mask                 button   function        argument       release */
static MouseShortcut mshortcuts[] = {
    {XK_NO_MOD, Button4, kscrollup, {.i = 3}},
    {XK_NO_MOD, Button5, kscrolldown, {.i = 3}},
    {XK_ANY_MOD, Button2, selpaste, {.i = 0}, 1},
    {ShiftMask, Button4, ttysend, {.s = "\033[5;2~"}},
    {XK_ANY_MOD, Button4, ttysend, {.s = "\031"}},
    {ShiftMask, Button5, ttysend, {.s = "\033[6;2~"}},
    {XK_ANY_MOD, Button5, ttysend, {.s = "\005"}},
};

/* Internal keyboard shortcuts. */
#define STKEY    (Mod1Mask | ControlMask)
#define ALTSHIFT (Mod1Mask | ShiftMask)
#define TERMMOD  (ControlMask | ShiftMask)

static char *copyurlcmd[] = {"/bin/sh", "-c", "st-urlhandler -o", "externalpipe", NULL};

// static char *copyoutput[] = {"/bin/sh", "-c", "st-copyout", "externalpipe",
//                              NULL};

static Shortcut shortcuts[] = {
    /* mask                 keysym          function        argument */
    {XK_ANY_MOD,  XK_Break,    sendbreak,     {.i = 0}         },
    {ControlMask, XK_Print,    toggleprinter, {.i = 0}         },
    {ShiftMask,   XK_Print,    printscreen,   {.i = 0}         },
    {XK_ANY_MOD,  XK_Print,    printsel,      {.i = 0}         },

    {STKEY,       XK_k,        zoom,          {.f = +1}        },
    {STKEY,       XK_j,        zoom,          {.f = -1}        },
    {STKEY,       XK_l,        externalpipe,  {.v = copyurlcmd}},
    {STKEY,       XK_u,        kscrollup,     {.i = -1}        },
    {STKEY,       XK_d,        kscrolldown,   {.i = -1}        },

    {TERMMOD,     XK_Home,     zoomreset,     {.f = 0}         },
    {TERMMOD,     XK_C,        clipcopy,      {.i = 0}         },
    {TERMMOD,     XK_V,        clippaste,     {.i = 0}         },
    {TERMMOD,     XK_Y,        selpaste,      {.i = 0}         },
    {ShiftMask,   XK_Insert,   selpaste,      {.i = 0}         },
    {TERMMOD,     XK_Num_Lock, numlock,       {.i = 0}         },
    // {ShiftMask, XK_Page_Up, kscrollup, {.i = -1}},
    // {ShiftMask, XK_Page_Down, kscrolldown, {.i = -1}},
};

/*
 * Special keys (change & recompile st.info accordingly)
 *
 * Mask value:
 * * Use XK_ANY_MOD to match the key no matter modifiers state
 * * Use XK_NO_MOD to match the key alone (no modifiers)
 * appkey value:
 * * 0: no value
 * * > 0: keypad application mode enabled
 * *   = 2: term.numlock = 1
 * * < 0: keypad application mode disabled
 * appcursor value:
 * * 0: no value
 * * > 0: cursor application mode enabled
 * * < 0: cursor application mode disabled
 *
 * Be careful with the order of the definitions because st searches in
 * this table sequentially, so any XK_ANY_MOD must be in the last
 * position for a key.
 */

/*
 * If you want keys other than the X11 function keys (0xFD00 - 0xFFFF)
 * to be mapped below, add them to this array.
 */

static KeySym mappedkeys[] = {
    XK_space,       XK_m,          XK_i,           XK_A,          XK_B,
    XK_C,           XK_D,          XK_E,           XK_F,          XK_G,
    XK_H,           XK_I,          XK_K,           XK_J,          XK_L,
    XK_M,           XK_N,          XK_O,           XK_P,          XK_Q,
    XK_R,           XK_S,          XK_T,           XK_U,          XK_V,
    XK_W,           XK_X,          XK_Y,           XK_Z,          XK_Z,
    XK_0,           XK_1,          XK_2,           XK_3,          XK_4,
    XK_5,           XK_6,          XK_7,           XK_8,          XK_9,
    XK_exclam,      XK_quotedbl,   XK_numbersign,  XK_dollar,     XK_percent,
    XK_ampersand,   XK_apostrophe, XK_parenleft,   XK_parenright, XK_asterisk,
    XK_plus,        XK_comma,      XK_minus,       XK_period,     XK_slash,
    XK_colon,       XK_semicolon,  XK_less,        XK_equal,      XK_greater,
    XK_question,    XK_at,         XK_bracketleft, XK_backslash,  XK_bracketright,
    XK_asciicircum, XK_underscore, XK_grave,       XK_braceleft,  XK_bar,
    XK_braceright,  XK_asciitilde,
};

/*
 * State bits to ignore when matching key or button events.  By default,
 * numlock (Mod2Mask) and keyboard layout (XK_SWITCH_MOD) are ignored.
 */
static uint ignoremod = Mod2Mask | XK_SWITCH_MOD;

/*
 * This is the huge key array which defines all compatibility to the Linux
 * world. Please decide about changes wisely.
 */
static Key key[] = {
    /* keysym           mask            string      appkey appcursor */
    {XK_KP_Home,      ShiftMask,                          "\033[2J",     0,  -1},
    {XK_KP_Prior,     ShiftMask,                          "\033[5;2~",   0,  0 },
    {XK_KP_End,       ControlMask,                        "\033[J",      -1, 0 },
    {XK_KP_End,       ControlMask,                        "\033[1;5F",   +1, 0 },
    {XK_KP_End,       ShiftMask,                          "\033[K",      -1, 0 },
    {XK_KP_End,       ShiftMask,                          "\033[1;2F",   +1, 0 },
    {XK_KP_Next,      ShiftMask,                          "\033[6;2~",   0,  0 },
    {XK_KP_Insert,    ShiftMask,                          "\033[2;2~",   +1, 0 },
    {XK_KP_Insert,    ShiftMask,                          "\033[4l",     -1, 0 },
    {XK_KP_Insert,    ControlMask,                        "\033[L",      -1, 0 },
    {XK_KP_Insert,    ControlMask,                        "\033[2;5~",   +1, 0 },
    {XK_KP_Delete,    ControlMask,                        "\033[M",      -1, 0 },
    {XK_KP_Delete,    ControlMask,                        "\033[3;5~",   +1, 0 },
    {XK_KP_Delete,    ShiftMask,                          "\033[2K",     -1, 0 },
    {XK_KP_Delete,    ShiftMask,                          "\033[3;2~",   +1, 0 },
    {XK_Up,           ShiftMask,                          "\033[1;2A",   0,  0 },
    {XK_Up,           Mod1Mask,                           "\033[1;3A",   0,  0 },
    {XK_Up,           ShiftMask | Mod1Mask,               "\033[1;4A",   0,  0 },
    {XK_Up,           ControlMask,                        "\033[1;5A",   0,  0 },
    {XK_Up,           ShiftMask | ControlMask,            "\033[1;6A",   0,  0 },
    {XK_Up,           ControlMask | Mod1Mask,             "\033[1;7A",   0,  0 },
    {XK_Up,           ShiftMask | ControlMask | Mod1Mask, "\033[1;8A",   0,  0 },
    {XK_Up,           XK_ANY_MOD,                         "\033[A",      0,  0 },
    {XK_Down,         ShiftMask,                          "\033[1;2B",   0,  0 },
    {XK_Down,         Mod1Mask,                           "\033[1;3B",   0,  0 },
    {XK_Down,         ShiftMask | Mod1Mask,               "\033[1;4B",   0,  0 },
    {XK_Down,         ControlMask,                        "\033[1;5B",   0,  0 },
    {XK_Down,         ShiftMask | ControlMask,            "\033[1;6B",   0,  0 },
    {XK_Down,         ControlMask | Mod1Mask,             "\033[1;7B",   0,  0 },
    {XK_Down,         ShiftMask | ControlMask | Mod1Mask, "\033[1;8B",   0,  0 },
    {XK_Down,         XK_ANY_MOD,                         "\033[B",      0,  0 },
    {XK_Left,         ShiftMask,                          "\033[1;2D",   0,  0 },
    {XK_Left,         Mod1Mask,                           "\033[1;3D",   0,  0 },
    {XK_Left,         ShiftMask | Mod1Mask,               "\033[1;4D",   0,  0 },
    {XK_Left,         ControlMask,                        "\033[1;5D",   0,  0 },
    {XK_Left,         ShiftMask | ControlMask,            "\033[1;6D",   0,  0 },
    {XK_Left,         ControlMask | Mod1Mask,             "\033[1;7D",   0,  0 },
    {XK_Left,         ShiftMask | ControlMask | Mod1Mask, "\033[1;8D",   0,  0 },
    {XK_Left,         XK_ANY_MOD,                         "\033[D",      0,  -1},
    {XK_Left,         XK_ANY_MOD,                         "\033OD",      0,  +1},
    {XK_Right,        ShiftMask,                          "\033[1;2C",   0,  0 },
    {XK_Right,        Mod1Mask,                           "\033[1;3C",   0,  0 },
    {XK_Right,        ShiftMask | Mod1Mask,               "\033[1;4C",   0,  0 },
    {XK_Right,        ControlMask,                        "\033[1;5C",   0,  0 },
    {XK_Right,        ShiftMask | ControlMask,            "\033[1;6C",   0,  0 },
    {XK_Right,        ControlMask | Mod1Mask,             "\033[1;7C",   0,  0 },
    {XK_Right,        ShiftMask | ControlMask | Mod1Mask, "\033[1;8C",   0,  0 },
    {XK_Right,        XK_ANY_MOD,                         "\033[C",      0,  -1},
    {XK_Right,        XK_ANY_MOD,                         "\033OC",      0,  +1},
    {XK_ISO_Left_Tab, ShiftMask,                          "\033[Z",      0,  0 },
    {XK_Return,       Mod1Mask,                           "\033\r",      0,  0 },
    {XK_Return,       XK_NO_MOD,                          "\r",          0,  0 },
    {XK_Insert,       ShiftMask,                          "\033[4l",     -1, 0 },
    {XK_Insert,       ShiftMask,                          "\033[2;2~",   +1, 0 },
    {XK_Insert,       ControlMask,                        "\033[L",      -1, 0 },
    {XK_Insert,       ControlMask,                        "\033[2;5~",   +1, 0 },
    {XK_Delete,       ControlMask,                        "\033[M",      -1, 0 },
    {XK_Delete,       ControlMask,                        "\033[3;5~",   +1, 0 },
    {XK_Delete,       ShiftMask,                          "\033[2K",     -1, 0 },
    {XK_Delete,       ShiftMask,                          "\033[3;2~",   +1, 0 },
    {XK_BackSpace,    XK_NO_MOD,                          "\177",        0,  0 },
    {XK_BackSpace,    Mod1Mask,                           "\033\177",    0,  0 },
    {XK_Home,         ShiftMask,                          "\033[2J",     0,  -1},
    {XK_Home,         ShiftMask,                          "\033[1;2H",   0,  +1},
    {XK_End,          ControlMask,                        "\033[J",      -1, 0 },
    {XK_End,          ControlMask,                        "\033[1;5F",   +1, 0 },
    {XK_End,          ShiftMask,                          "\033[K",      -1, 0 },
    {XK_End,          ShiftMask,                          "\033[1;2F",   +1, 0 },
    {XK_Prior,        ControlMask,                        "\033[5;5~",   0,  0 },
    {XK_Prior,        ShiftMask,                          "\033[5;2~",   0,  0 },
    {XK_Next,         ControlMask,                        "\033[6;5~",   0,  0 },
    {XK_Next,         ShiftMask,                          "\033[6;2~",   0,  0 },
    {XK_F1,           XK_NO_MOD,                          "\033OP",      0,  0 },
    {XK_F1,           /* F13 */ ShiftMask,                "\033[1;2P",   0,  0 },
    {XK_F1,           /* F25 */ ControlMask,              "\033[1;5P",   0,  0 },
    {XK_F1,           /* F37 */ Mod4Mask,                 "\033[1;6P",   0,  0 },
    {XK_F1,           /* F49 */ Mod1Mask,                 "\033[1;3P",   0,  0 },
    {XK_F1,           /* F61 */ Mod3Mask,                 "\033[1;4P",   0,  0 },
    {XK_F2,           XK_NO_MOD,                          "\033OQ",      0,  0 },
    {XK_F2,           /* F14 */ ShiftMask,                "\033[1;2Q",   0,  0 },
    {XK_F2,           /* F26 */ ControlMask,              "\033[1;5Q",   0,  0 },
    {XK_F2,           /* F38 */ Mod4Mask,                 "\033[1;6Q",   0,  0 },
    {XK_F2,           /* F50 */ Mod1Mask,                 "\033[1;3Q",   0,  0 },
    {XK_F2,           /* F62 */ Mod3Mask,                 "\033[1;4Q",   0,  0 },
    {XK_F3,           XK_NO_MOD,                          "\033OR",      0,  0 },
    {XK_F3,           /* F15 */ ShiftMask,                "\033[1;2R",   0,  0 },
    {XK_F3,           /* F27 */ ControlMask,              "\033[1;5R",   0,  0 },
    {XK_F3,           /* F39 */ Mod4Mask,                 "\033[1;6R",   0,  0 },
    {XK_F3,           /* F51 */ Mod1Mask,                 "\033[1;3R",   0,  0 },
    {XK_F3,           /* F63 */ Mod3Mask,                 "\033[1;4R",   0,  0 },
    {XK_F4,           XK_NO_MOD,                          "\033OS",      0,  0 },
    {XK_F4,           /* F16 */ ShiftMask,                "\033[1;2S",   0,  0 },
    {XK_F4,           /* F28 */ ControlMask,              "\033[1;5S",   0,  0 },
    {XK_F4,           /* F40 */ Mod4Mask,                 "\033[1;6S",   0,  0 },
    {XK_F4,           /* F52 */ Mod1Mask,                 "\033[1;3S",   0,  0 },
    {XK_F5,           XK_NO_MOD,                          "\033[15~",    0,  0 },
    {XK_F5,           /* F17 */ ShiftMask,                "\033[15;2~",  0,  0 },
    {XK_F5,           /* F29 */ ControlMask,              "\033[15;5~",  0,  0 },
    {XK_F5,           /* F41 */ Mod4Mask,                 "\033[15;6~",  0,  0 },
    {XK_F5,           /* F53 */ Mod1Mask,                 "\033[15;3~",  0,  0 },
    {XK_F6,           XK_NO_MOD,                          "\033[17~",    0,  0 },
    {XK_F6,           /* F18 */ ShiftMask,                "\033[17;2~",  0,  0 },
    {XK_F6,           /* F30 */ ControlMask,              "\033[17;5~",  0,  0 },
    {XK_F6,           /* F42 */ Mod4Mask,                 "\033[17;6~",  0,  0 },
    {XK_F6,           /* F54 */ Mod1Mask,                 "\033[17;3~",  0,  0 },
    {XK_F7,           XK_NO_MOD,                          "\033[18~",    0,  0 },
    {XK_F7,           /* F19 */ ShiftMask,                "\033[18;2~",  0,  0 },
    {XK_F7,           /* F31 */ ControlMask,              "\033[18;5~",  0,  0 },
    {XK_F7,           /* F43 */ Mod4Mask,                 "\033[18;6~",  0,  0 },
    {XK_F7,           /* F55 */ Mod1Mask,                 "\033[18;3~",  0,  0 },
    {XK_F8,           XK_NO_MOD,                          "\033[19~",    0,  0 },
    {XK_F8,           /* F20 */ ShiftMask,                "\033[19;2~",  0,  0 },
    {XK_F8,           /* F32 */ ControlMask,              "\033[19;5~",  0,  0 },
    {XK_F8,           /* F44 */ Mod4Mask,                 "\033[19;6~",  0,  0 },
    {XK_F8,           /* F56 */ Mod1Mask,                 "\033[19;3~",  0,  0 },
    {XK_F9,           XK_NO_MOD,                          "\033[20~",    0,  0 },
    {XK_F9,           /* F21 */ ShiftMask,                "\033[20;2~",  0,  0 },
    {XK_F9,           /* F33 */ ControlMask,              "\033[20;5~",  0,  0 },
    {XK_F9,           /* F45 */ Mod4Mask,                 "\033[20;6~",  0,  0 },
    {XK_F9,           /* F57 */ Mod1Mask,                 "\033[20;3~",  0,  0 },
    {XK_F10,          XK_NO_MOD,                          "\033[21~",    0,  0 },
    {XK_F10,          /* F22 */ ShiftMask,                "\033[21;2~",  0,  0 },
    {XK_F10,          /* F34 */ ControlMask,              "\033[21;5~",  0,  0 },
    {XK_F10,          /* F46 */ Mod4Mask,                 "\033[21;6~",  0,  0 },
    {XK_F10,          /* F58 */ Mod1Mask,                 "\033[21;3~",  0,  0 },
    {XK_F11,          XK_NO_MOD,                          "\033[23~",    0,  0 },
    {XK_F11,          /* F23 */ ShiftMask,                "\033[23;2~",  0,  0 },
    {XK_F11,          /* F35 */ ControlMask,              "\033[23;5~",  0,  0 },
    {XK_F11,          /* F47 */ Mod4Mask,                 "\033[23;6~",  0,  0 },
    {XK_F11,          /* F59 */ Mod1Mask,                 "\033[23;3~",  0,  0 },
    {XK_F12,          XK_NO_MOD,                          "\033[24~",    0,  0 },
    {XK_F12,          /* F24 */ ShiftMask,                "\033[24;2~",  0,  0 },
    {XK_F12,          /* F36 */ ControlMask,              "\033[24;5~",  0,  0 },
    {XK_F12,          /* F48 */ Mod4Mask,                 "\033[24;6~",  0,  0 },
    {XK_F12,          /* F60 */ Mod1Mask,                 "\033[24;3~",  0,  0 },
    {XK_F13,          XK_NO_MOD,                          "\033[1;2P",   0,  0 },
    {XK_F14,          XK_NO_MOD,                          "\033[1;2Q",   0,  0 },
    {XK_F15,          XK_NO_MOD,                          "\033[1;2R",   0,  0 },
    {XK_F16,          XK_NO_MOD,                          "\033[1;2S",   0,  0 },
    {XK_F17,          XK_NO_MOD,                          "\033[15;2~",  0,  0 },
    {XK_F18,          XK_NO_MOD,                          "\033[17;2~",  0,  0 },
    {XK_F19,          XK_NO_MOD,                          "\033[18;2~",  0,  0 },
    {XK_F20,          XK_NO_MOD,                          "\033[19;2~",  0,  0 },
    {XK_F21,          XK_NO_MOD,                          "\033[20;2~",  0,  0 },
    {XK_F22,          XK_NO_MOD,                          "\033[21;2~",  0,  0 },
    {XK_F23,          XK_NO_MOD,                          "\033[23;2~",  0,  0 },
    {XK_F24,          XK_NO_MOD,                          "\033[24;2~",  0,  0 },
    {XK_F25,          XK_NO_MOD,                          "\033[1;5P",   0,  0 },
    {XK_F26,          XK_NO_MOD,                          "\033[1;5Q",   0,  0 },
    {XK_F27,          XK_NO_MOD,                          "\033[1;5R",   0,  0 },
    {XK_F28,          XK_NO_MOD,                          "\033[1;5S",   0,  0 },
    {XK_F29,          XK_NO_MOD,                          "\033[15;5~",  0,  0 },
    {XK_F30,          XK_NO_MOD,                          "\033[17;5~",  0,  0 },
    {XK_F31,          XK_NO_MOD,                          "\033[18;5~",  0,  0 },
    {XK_F32,          XK_NO_MOD,                          "\033[19;5~",  0,  0 },
    {XK_F33,          XK_NO_MOD,                          "\033[20;5~",  0,  0 },
    {XK_F34,          XK_NO_MOD,                          "\033[21;5~",  0,  0 },
    {XK_F35,          XK_NO_MOD,                          "\033[23;5~",  0,  0 },

    // libtermkey compatible keyboard input
    {XK_KP_Home,      XK_NO_MOD,                          "\033[H",      0,  -1},
    {XK_KP_Home,      XK_NO_MOD,                          "\033[1~",     0,  +1},
    {XK_KP_Home,      ControlMask,                        "\033[149;5u", 0,  0 },
    {XK_KP_Home,      ControlMask | ShiftMask,            "\033[149;6u", 0,  0 },
    {XK_KP_Home,      Mod1Mask,                           "\033[149;3u", 0,  0 },
    {XK_KP_Home,      Mod1Mask | ControlMask,             "\033[149;7u", 0,  0 },
    {XK_KP_Home,      Mod1Mask | ControlMask | ShiftMask, "\033[149;8u", 0,  0 },
    {XK_KP_Home,      Mod1Mask | ShiftMask,               "\033[149;4u", 0,  0 },
    {XK_KP_Home,      ShiftMask,                          "\033[149;2u", 0,  0 },
    {XK_KP_Up,        XK_NO_MOD,                          "\033Ox",      +1, 0 },
    {XK_KP_Up,        XK_NO_MOD,                          "\033[A",      0,  -1},
    {XK_KP_Up,        XK_NO_MOD,                          "\033OA",      0,  +1},
    {XK_KP_Up,        ControlMask,                        "\033[151;5u", 0,  0 },
    {XK_KP_Up,        ControlMask | ShiftMask,            "\033[151;6u", 0,  0 },
    {XK_KP_Up,        Mod1Mask,                           "\033[151;3u", 0,  0 },
    {XK_KP_Up,        Mod1Mask | ControlMask,             "\033[151;7u", 0,  0 },
    {XK_KP_Up,        Mod1Mask | ControlMask | ShiftMask, "\033[151;8u", 0,  0 },
    {XK_KP_Up,        Mod1Mask | ShiftMask,               "\033[151;4u", 0,  0 },
    {XK_KP_Up,        ShiftMask,                          "\033[151;2u", 0,  0 },
    {XK_KP_Down,      XK_NO_MOD,                          "\033Or",      +1, 0 },
    {XK_KP_Down,      XK_NO_MOD,                          "\033[B",      0,  -1},
    {XK_KP_Down,      XK_NO_MOD,                          "\033OB",      0,  +1},
    {XK_KP_Down,      ControlMask,                        "\033[153;5u", 0,  0 },
    {XK_KP_Down,      ControlMask | ShiftMask,            "\033[153;6u", 0,  0 },
    {XK_KP_Down,      Mod1Mask,                           "\033[153;3u", 0,  0 },
    {XK_KP_Down,      Mod1Mask | ControlMask,             "\033[153;7u", 0,  0 },
    {XK_KP_Down,      Mod1Mask | ControlMask | ShiftMask, "\033[153;8u", 0,  0 },
    {XK_KP_Down,      Mod1Mask | ShiftMask,               "\033[153;4u", 0,  0 },
    {XK_KP_Down,      ShiftMask,                          "\033[153;2u", 0,  0 },
    {XK_KP_Left,      XK_NO_MOD,                          "\033Ot",      +1, 0 },
    {XK_KP_Left,      XK_NO_MOD,                          "\033[D",      0,  -1},
    {XK_KP_Left,      XK_NO_MOD,                          "\033OD",      0,  +1},
    {XK_KP_Left,      ControlMask,                        "\033[150;5u", 0,  0 },
    {XK_KP_Left,      ControlMask | ShiftMask,            "\033[150;6u", 0,  0 },
    {XK_KP_Left,      Mod1Mask,                           "\033[150;3u", 0,  0 },
    {XK_KP_Left,      Mod1Mask | ControlMask,             "\033[150;7u", 0,  0 },
    {XK_KP_Left,      Mod1Mask | ControlMask | ShiftMask, "\033[150;8u", 0,  0 },
    {XK_KP_Left,      Mod1Mask | ShiftMask,               "\033[150;4u", 0,  0 },
    {XK_KP_Left,      ShiftMask,                          "\033[150;2u", 0,  0 },
    {XK_KP_Right,     XK_NO_MOD,                          "\033Ov",      +1, 0 },
    {XK_KP_Right,     XK_NO_MOD,                          "\033[C",      0,  -1},
    {XK_KP_Right,     XK_NO_MOD,                          "\033OC",      0,  +1},
    {XK_KP_Right,     ControlMask,                        "\033[152;5u", 0,  0 },
    {XK_KP_Right,     ControlMask | ShiftMask,            "\033[152;6u", 0,  0 },
    {XK_KP_Right,     Mod1Mask,                           "\033[152;3u", 0,  0 },
    {XK_KP_Right,     Mod1Mask | ControlMask,             "\033[152;7u", 0,  0 },
    {XK_KP_Right,     Mod1Mask | ControlMask | ShiftMask, "\033[152;8u", 0,  0 },
    {XK_KP_Right,     Mod1Mask | ShiftMask,               "\033[152;4u", 0,  0 },
    {XK_KP_Right,     ShiftMask,                          "\033[152;2u", 0,  0 },
    {XK_KP_Prior,     XK_NO_MOD,                          "\033[5~",     0,  0 },
    {XK_KP_Prior,     ControlMask,                        "\033[154;5u", 0,  0 },
    {XK_KP_Prior,     ControlMask | ShiftMask,            "\033[154;6u", 0,  0 },
    {XK_KP_Prior,     Mod1Mask,                           "\033[154;3u", 0,  0 },
    {XK_KP_Prior,     Mod1Mask | ControlMask,             "\033[154;7u", 0,  0 },
    {XK_KP_Prior,     Mod1Mask | ControlMask | ShiftMask, "\033[154;8u", 0,  0 },
    {XK_KP_Prior,     Mod1Mask | ShiftMask,               "\033[154;4u", 0,  0 },
    {XK_KP_Begin,     XK_NO_MOD,                          "\033[E",      0,  0 },
    {XK_KP_Begin,     ControlMask,                        "\033[157;5u", 0,  0 },
    {XK_KP_Begin,     ControlMask | ShiftMask,            "\033[157;6u", 0,  0 },
    {XK_KP_Begin,     Mod1Mask,                           "\033[157;3u", 0,  0 },
    {XK_KP_Begin,     Mod1Mask | ControlMask,             "\033[157;7u", 0,  0 },
    {XK_KP_Begin,     Mod1Mask | ControlMask | ShiftMask, "\033[157;8u", 0,  0 },
    {XK_KP_Begin,     Mod1Mask | ShiftMask,               "\033[157;4u", 0,  0 },
    {XK_KP_Begin,     ShiftMask,                          "\033[157;2u", 0,  0 },
    {XK_KP_End,       XK_NO_MOD,                          "\033[4~",     0,  0 },
    {XK_KP_End,       ControlMask | ShiftMask,            "\033[156;6u", 0,  0 },
    {XK_KP_End,       Mod1Mask,                           "\033[156;3u", 0,  0 },
    {XK_KP_End,       Mod1Mask | ControlMask,             "\033[156;7u", 0,  0 },
    {XK_KP_End,       Mod1Mask | ControlMask | ShiftMask, "\033[156;8u", 0,  0 },
    {XK_KP_End,       Mod1Mask | ShiftMask,               "\033[156;4u", 0,  0 },
    {XK_KP_Next,      XK_NO_MOD,                          "\033[6~",     0,  0 },
    {XK_KP_Next,      ControlMask,                        "\033[155;5u", 0,  0 },
    {XK_KP_Next,      ControlMask | ShiftMask,            "\033[155;6u", 0,  0 },
    {XK_KP_Next,      Mod1Mask,                           "\033[155;3u", 0,  0 },
    {XK_KP_Next,      Mod1Mask | ControlMask,             "\033[155;7u", 0,  0 },
    {XK_KP_Next,      Mod1Mask | ControlMask | ShiftMask, "\033[155;8u", 0,  0 },
    {XK_KP_Next,      Mod1Mask | ShiftMask,               "\033[155;4u", 0,  0 },
    {XK_KP_Insert,    XK_NO_MOD,                          "\033[4h",     -1, 0 },
    {XK_KP_Insert,    XK_NO_MOD,                          "\033[2~",     +1, 0 },
    {XK_KP_Insert,    ControlMask | ShiftMask,            "\033[158;6u", 0,  0 },
    {XK_KP_Insert,    Mod1Mask,                           "\033[158;3u", 0,  0 },
    {XK_KP_Insert,    Mod1Mask | ControlMask,             "\033[158;7u", 0,  0 },
    {XK_KP_Insert,    Mod1Mask | ControlMask | ShiftMask, "\033[158;8u", 0,  0 },
    {XK_KP_Insert,    Mod1Mask | ShiftMask,               "\033[158;4u", 0,  0 },
    {XK_KP_Delete,    XK_NO_MOD,                          "\033[P",      -1, 0 },
    {XK_KP_Delete,    XK_NO_MOD,                          "\033[3~",     +1, 0 },
    {XK_KP_Delete,    ControlMask | ShiftMask,            "\033[159;6u", 0,  0 },
    {XK_KP_Delete,    Mod1Mask,                           "\033[159;3u", 0,  0 },
    {XK_KP_Delete,    Mod1Mask | ControlMask,             "\033[159;7u", 0,  0 },
    {XK_KP_Delete,    Mod1Mask | ControlMask | ShiftMask, "\033[159;8u", 0,  0 },
    {XK_KP_Delete,    Mod1Mask | ShiftMask,               "\033[159;4u", 0,  0 },
    {XK_KP_Multiply,  XK_NO_MOD,                          "\033Oj",      +2, 0 },
    {XK_KP_Multiply,  ControlMask,                        "\033[170;5u", 0,  0 },
    {XK_KP_Multiply,  ControlMask | ShiftMask,            "\033[170;6u", 0,  0 },
    {XK_KP_Multiply,  Mod1Mask,                           "\033[170;3u", 0,  0 },
    {XK_KP_Multiply,  Mod1Mask | ControlMask,             "\033[170;7u", 0,  0 },
    {XK_KP_Multiply,  Mod1Mask | ControlMask | ShiftMask, "\033[170;8u", 0,  0 },
    {XK_KP_Multiply,  Mod1Mask | ShiftMask,               "\033[170;4u", 0,  0 },
    {XK_KP_Multiply,  ShiftMask,                          "\033[170;2u", 0,  0 },
    {XK_KP_Add,       XK_NO_MOD,                          "\033Ok",      +2, 0 },
    {XK_KP_Add,       ControlMask,                        "\033[171;5u", 0,  0 },
    {XK_KP_Add,       ControlMask | ShiftMask,            "\033[171;6u", 0,  0 },
    {XK_KP_Add,       Mod1Mask,                           "\033[171;3u", 0,  0 },
    {XK_KP_Add,       Mod1Mask | ControlMask,             "\033[171;7u", 0,  0 },
    {XK_KP_Add,       Mod1Mask | ControlMask | ShiftMask, "\033[171;8u", 0,  0 },
    {XK_KP_Add,       Mod1Mask | ShiftMask,               "\033[171;4u", 0,  0 },
    {XK_KP_Add,       ShiftMask,                          "\033[171;2u", 0,  0 },
    {XK_KP_Enter,     XK_NO_MOD,                          "\033OM",      +2, 0 },
    {XK_KP_Enter,     XK_NO_MOD,                          "\r",          -1, 0 },
    {XK_KP_Enter,     XK_NO_MOD,                          "\r\n",        -1, 0 },
    {XK_KP_Enter,     ControlMask,                        "\033[141;5u", 0,  0 },
    {XK_KP_Enter,     ControlMask | ShiftMask,            "\033[141;6u", 0,  0 },
    {XK_KP_Enter,     Mod1Mask,                           "\033[141;3u", 0,  0 },
    {XK_KP_Enter,     Mod1Mask | ControlMask,             "\033[141;7u", 0,  0 },
    {XK_KP_Enter,     Mod1Mask | ControlMask | ShiftMask, "\033[141;8u", 0,  0 },
    {XK_KP_Enter,     Mod1Mask | ShiftMask,               "\033[141;4u", 0,  0 },
    {XK_KP_Enter,     ShiftMask,                          "\033[141;2u", 0,  0 },
    {XK_KP_Subtract,  XK_NO_MOD,                          "\033Om",      +2, 0 },
    {XK_KP_Subtract,  ControlMask,                        "\033[173;5u", 0,  0 },
    {XK_KP_Subtract,  ControlMask | ShiftMask,            "\033[173;6u", 0,  0 },
    {XK_KP_Subtract,  Mod1Mask,                           "\033[173;3u", 0,  0 },
    {XK_KP_Subtract,  Mod1Mask | ControlMask,             "\033[173;7u", 0,  0 },
    {XK_KP_Subtract,  Mod1Mask | ControlMask | ShiftMask, "\033[173;8u", 0,  0 },
    {XK_KP_Subtract,  Mod1Mask | ShiftMask,               "\033[173;4u", 0,  0 },
    {XK_KP_Subtract,  ShiftMask,                          "\033[173;2u", 0,  0 },
    {XK_KP_Decimal,   XK_NO_MOD,                          "\033On",      +2, 0 },
    {XK_KP_Decimal,   ControlMask,                        "\033[174;5u", 0,  0 },
    {XK_KP_Decimal,   ControlMask | ShiftMask,            "\033[174;6u", 0,  0 },
    {XK_KP_Decimal,   Mod1Mask,                           "\033[174;3u", 0,  0 },
    {XK_KP_Decimal,   Mod1Mask | ControlMask,             "\033[174;7u", 0,  0 },
    {XK_KP_Decimal,   Mod1Mask | ControlMask | ShiftMask, "\033[174;8u", 0,  0 },
    {XK_KP_Decimal,   Mod1Mask | ShiftMask,               "\033[174;4u", 0,  0 },
    {XK_KP_Decimal,   ShiftMask,                          "\033[174;2u", 0,  0 },
    {XK_KP_Divide,    XK_NO_MOD,                          "\033Oo",      +2, 0 },
    {XK_KP_Divide,    ControlMask,                        "\033[175;5u", 0,  0 },
    {XK_KP_Divide,    ControlMask | ShiftMask,            "\033[175;6u", 0,  0 },
    {XK_KP_Divide,    Mod1Mask,                           "\033[175;3u", 0,  0 },
    {XK_KP_Divide,    Mod1Mask | ControlMask,             "\033[175;7u", 0,  0 },
    {XK_KP_Divide,    Mod1Mask | ControlMask | ShiftMask, "\033[175;8u", 0,  0 },
    {XK_KP_Divide,    Mod1Mask | ShiftMask,               "\033[175;4u", 0,  0 },
    {XK_KP_Divide,    ShiftMask,                          "\033[175;2u", 0,  0 },
    {XK_KP_0,         XK_NO_MOD,                          "\033Op",      +2, 0 },
    {XK_KP_0,         ControlMask,                        "\033[176;5u", 0,  0 },
    {XK_KP_0,         ControlMask | ShiftMask,            "\033[176;6u", 0,  0 },
    {XK_KP_0,         Mod1Mask,                           "\033[176;3u", 0,  0 },
    {XK_KP_0,         Mod1Mask | ControlMask,             "\033[176;7u", 0,  0 },
    {XK_KP_0,         Mod1Mask | ControlMask | ShiftMask, "\033[176;8u", 0,  0 },
    {XK_KP_0,         Mod1Mask | ShiftMask,               "\033[176;4u", 0,  0 },
    {XK_KP_0,         ShiftMask,                          "\033[176;2u", 0,  0 },
    {XK_KP_1,         XK_NO_MOD,                          "\033Oq",      +2, 0 },
    {XK_KP_0,         ControlMask,                        "\033[177;5u", 0,  0 },
    {XK_KP_0,         ControlMask | ShiftMask,            "\033[177;6u", 0,  0 },
    {XK_KP_0,         Mod1Mask,                           "\033[177;3u", 0,  0 },
    {XK_KP_0,         Mod1Mask | ControlMask,             "\033[177;7u", 0,  0 },
    {XK_KP_0,         Mod1Mask | ControlMask | ShiftMask, "\033[177;8u", 0,  0 },
    {XK_KP_0,         Mod1Mask | ShiftMask,               "\033[177;4u", 0,  0 },
    {XK_KP_0,         ShiftMask,                          "\033[177;2u", 0,  0 },
    {XK_KP_2,         XK_NO_MOD,                          "\033Or",      +2, 0 },
    {XK_KP_2,         ControlMask,                        "\033[178;5u", 0,  0 },
    {XK_KP_2,         ControlMask | ShiftMask,            "\033[178;6u", 0,  0 },
    {XK_KP_2,         Mod1Mask,                           "\033[178;3u", 0,  0 },
    {XK_KP_2,         Mod1Mask | ControlMask,             "\033[178;7u", 0,  0 },
    {XK_KP_2,         Mod1Mask | ControlMask | ShiftMask, "\033[178;8u", 0,  0 },
    {XK_KP_2,         Mod1Mask | ShiftMask,               "\033[178;4u", 0,  0 },
    {XK_KP_2,         ShiftMask,                          "\033[178;2u", 0,  0 },
    {XK_KP_3,         XK_NO_MOD,                          "\033Os",      +2, 0 },
    {XK_KP_3,         ControlMask,                        "\033[179;5u", 0,  0 },
    {XK_KP_3,         ControlMask | ShiftMask,            "\033[179;6u", 0,  0 },
    {XK_KP_3,         Mod1Mask,                           "\033[179;3u", 0,  0 },
    {XK_KP_3,         Mod1Mask | ControlMask,             "\033[179;7u", 0,  0 },
    {XK_KP_3,         Mod1Mask | ControlMask | ShiftMask, "\033[179;8u", 0,  0 },
    {XK_KP_3,         Mod1Mask | ShiftMask,               "\033[179;4u", 0,  0 },
    {XK_KP_3,         ShiftMask,                          "\033[179;2u", 0,  0 },
    {XK_KP_4,         XK_NO_MOD,                          "\033Ot",      +2, 0 },
    {XK_KP_4,         ControlMask,                        "\033[180;5u", 0,  0 },
    {XK_KP_4,         ControlMask | ShiftMask,            "\033[180;6u", 0,  0 },
    {XK_KP_4,         Mod1Mask,                           "\033[180;3u", 0,  0 },
    {XK_KP_4,         Mod1Mask | ControlMask,             "\033[180;7u", 0,  0 },
    {XK_KP_4,         Mod1Mask | ControlMask | ShiftMask, "\033[180;8u", 0,  0 },
    {XK_KP_4,         Mod1Mask | ShiftMask,               "\033[180;4u", 0,  0 },
    {XK_KP_4,         ShiftMask,                          "\033[180;2u", 0,  0 },
    {XK_KP_5,         XK_NO_MOD,                          "\033Ou",      +2, 0 },
    {XK_KP_5,         ControlMask,                        "\033[181;5u", 0,  0 },
    {XK_KP_5,         ControlMask | ShiftMask,            "\033[181;6u", 0,  0 },
    {XK_KP_5,         Mod1Mask,                           "\033[181;3u", 0,  0 },
    {XK_KP_5,         Mod1Mask | ControlMask,             "\033[181;7u", 0,  0 },
    {XK_KP_5,         Mod1Mask | ControlMask | ShiftMask, "\033[181;8u", 0,  0 },
    {XK_KP_5,         Mod1Mask | ShiftMask,               "\033[181;4u", 0,  0 },
    {XK_KP_5,         ShiftMask,                          "\033[181;2u", 0,  0 },
    {XK_KP_6,         XK_NO_MOD,                          "\033Ov",      +2, 0 },
    {XK_KP_6,         ControlMask,                        "\033[182;5u", 0,  0 },
    {XK_KP_6,         ControlMask | ShiftMask,            "\033[182;6u", 0,  0 },
    {XK_KP_6,         Mod1Mask,                           "\033[182;3u", 0,  0 },
    {XK_KP_6,         Mod1Mask | ControlMask,             "\033[182;7u", 0,  0 },
    {XK_KP_6,         Mod1Mask | ControlMask | ShiftMask, "\033[182;8u", 0,  0 },
    {XK_KP_6,         Mod1Mask | ShiftMask,               "\033[182;4u", 0,  0 },
    {XK_KP_6,         ShiftMask,                          "\033[182;2u", 0,  0 },
    {XK_KP_7,         XK_NO_MOD,                          "\033Ow",      +2, 0 },
    {XK_KP_7,         ControlMask,                        "\033[183;5u", 0,  0 },
    {XK_KP_7,         ControlMask | ShiftMask,            "\033[183;6u", 0,  0 },
    {XK_KP_7,         Mod1Mask,                           "\033[183;3u", 0,  0 },
    {XK_KP_7,         Mod1Mask | ControlMask,             "\033[183;7u", 0,  0 },
    {XK_KP_7,         Mod1Mask | ControlMask | ShiftMask, "\033[183;8u", 0,  0 },
    {XK_KP_7,         Mod1Mask | ShiftMask,               "\033[183;4u", 0,  0 },
    {XK_KP_7,         ShiftMask,                          "\033[183;2u", 0,  0 },
    {XK_KP_8,         XK_NO_MOD,                          "\033Ox",      +2, 0 },
    {XK_KP_8,         ControlMask,                        "\033[184;5u", 0,  0 },
    {XK_KP_8,         ControlMask | ShiftMask,            "\033[184;6u", 0,  0 },
    {XK_KP_8,         Mod1Mask,                           "\033[184;3u", 0,  0 },
    {XK_KP_8,         Mod1Mask | ControlMask,             "\033[184;7u", 0,  0 },
    {XK_KP_8,         Mod1Mask | ControlMask | ShiftMask, "\033[184;8u", 0,  0 },
    {XK_KP_8,         Mod1Mask | ShiftMask,               "\033[184;4u", 0,  0 },
    {XK_KP_8,         ShiftMask,                          "\033[184;2u", 0,  0 },
    {XK_KP_9,         XK_NO_MOD,                          "\033Oy",      +2, 0 },
    {XK_KP_9,         ControlMask,                        "\033[185;5u", 0,  0 },
    {XK_KP_9,         ControlMask | ShiftMask,            "\033[185;6u", 0,  0 },
    {XK_KP_9,         Mod1Mask,                           "\033[185;3u", 0,  0 },
    {XK_KP_9,         Mod1Mask | ControlMask,             "\033[185;7u", 0,  0 },
    {XK_KP_9,         Mod1Mask | ControlMask | ShiftMask, "\033[185;8u", 0,  0 },
    {XK_KP_9,         Mod1Mask | ShiftMask,               "\033[185;4u", 0,  0 },
    {XK_KP_9,         ShiftMask,                          "\033[185;2u", 0,  0 },
    {XK_BackSpace,    ControlMask,                        "\033[127;5u", 0,  0 },
    {XK_BackSpace,    ControlMask | ShiftMask,            "\033[127;6u", 0,  0 },
    {XK_BackSpace,    Mod1Mask,                           "\033[127;3u", 0,  0 },
    {XK_BackSpace,    Mod1Mask | ControlMask,             "\033[127;7u", 0,  0 },
    {XK_BackSpace,    Mod1Mask | ControlMask | ShiftMask, "\033[127;8u", 0,  0 },
    {XK_BackSpace,    Mod1Mask | ShiftMask,               "\033[127;4u", 0,  0 },
    {XK_BackSpace,    ShiftMask,                          "\033[127;2u", 0,  0 },
    {XK_Tab,          ControlMask,                        "\033[9;5u",   0,  0 },
    {XK_Tab,          ControlMask | ShiftMask,            "\033[1;5Z",   0,  0 },
    {XK_Tab,          Mod1Mask,                           "\033[1;3Z",   0,  0 },
    {XK_Tab,          Mod1Mask | ControlMask,             "\033[1;7Z",   0,  0 },
    {XK_Tab,          Mod1Mask | ControlMask | ShiftMask, "\033[1;8Z",   0,  0 },
    {XK_Tab,          Mod1Mask | ShiftMask,               "\033[1;4Z",   0,  0 },
    {XK_Return,       ControlMask,                        "\033[13;5u",  0,  0 },
    {XK_Return,       ControlMask | ShiftMask,            "\033[13;6u",  0,  0 },
    {XK_Return,       Mod1Mask,                           "\033[13;3u",  0,  0 },
    {XK_Return,       Mod1Mask | ControlMask,             "\033[13;7u",  0,  0 },
    {XK_Return,       Mod1Mask | ControlMask | ShiftMask, "\033[13;8u",  0,  0 },
    {XK_Return,       Mod1Mask | ShiftMask,               "\033[13;4u",  0,  0 },
    {XK_Return,       ShiftMask,                          "\033[13;2u",  0,  0 },
    {XK_Pause,        ControlMask,                        "\033[18;5u",  0,  0 },
    {XK_Pause,        ControlMask | ShiftMask,            "\033[18;6u",  0,  0 },
    {XK_Pause,        Mod1Mask,                           "\033[18;3u",  0,  0 },
    {XK_Pause,        Mod1Mask | ControlMask,             "\033[18;7u",  0,  0 },
    {XK_Pause,        Mod1Mask | ControlMask | ShiftMask, "\033[18;8u",  0,  0 },
    {XK_Pause,        Mod1Mask | ShiftMask,               "\033[18;4u",  0,  0 },
    {XK_Pause,        ShiftMask,                          "\033[18;2u",  0,  0 },
    {XK_Scroll_Lock,  ControlMask,                        "\033[20;5u",  0,  0 },
    {XK_Scroll_Lock,  ControlMask | ShiftMask,            "\033[20;6u",  0,  0 },
    {XK_Scroll_Lock,  Mod1Mask,                           "\033[20;3u",  0,  0 },
    {XK_Scroll_Lock,  Mod1Mask | ControlMask,             "\033[20;7u",  0,  0 },
    {XK_Scroll_Lock,  Mod1Mask | ControlMask | ShiftMask, "\033[20;8u",  0,  0 },
    {XK_Scroll_Lock,  Mod1Mask | ShiftMask,               "\033[20;4u",  0,  0 },
    {XK_Scroll_Lock,  ShiftMask,                          "\033[20;2u",  0,  0 },
    {XK_Escape,       ControlMask,                        "\033[27;5u",  0,  0 },
    {XK_Escape,       ControlMask | ShiftMask,            "\033[27;6u",  0,  0 },
    {XK_Escape,       Mod1Mask,                           "\033[27;3u",  0,  0 },
    {XK_Escape,       Mod1Mask | ControlMask,             "\033[27;7u",  0,  0 },
    {XK_Escape,       Mod1Mask | ControlMask | ShiftMask, "\033[27;8u",  0,  0 },
    {XK_Escape,       Mod1Mask | ShiftMask,               "\033[27;4u",  0,  0 },
    {XK_Escape,       ShiftMask,                          "\033[27;2u",  0,  0 },
    {XK_Home,         XK_NO_MOD,                          "\033[H",      0,  -1},
    {XK_Home,         XK_NO_MOD,                          "\033[1~",     0,  +1},
    {XK_Home,         ControlMask | ShiftMask,            "\033[80;6u",  0,  0 },
    {XK_Home,         Mod1Mask,                           "\033[80;3u",  0,  0 },
    {XK_Home,         Mod1Mask | ControlMask,             "\033[80;7u",  0,  0 },
    {XK_Home,         Mod1Mask | ControlMask | ShiftMask, "\033[80;8u",  0,  0 },
    {XK_Home,         Mod1Mask | ShiftMask,               "\033[80;4u",  0,  0 },
    {XK_End,          XK_NO_MOD,                          "\033[4~",     0,  0 },
    {XK_End,          ControlMask | ShiftMask,            "\033[87;6u",  0,  0 },
    {XK_End,          Mod1Mask,                           "\033[87;3u",  0,  0 },
    {XK_End,          Mod1Mask | ControlMask,             "\033[87;7u",  0,  0 },
    {XK_End,          Mod1Mask | ControlMask | ShiftMask, "\033[87;8u",  0,  0 },
    {XK_End,          Mod1Mask | ShiftMask,               "\033[87;4u",  0,  0 },
    {XK_Prior,        XK_NO_MOD,                          "\033[5~",     0,  0 },
    {XK_Prior,        ControlMask | ShiftMask,            "\033[85;6u",  0,  0 },
    {XK_Prior,        Mod1Mask,                           "\033[85;3u",  0,  0 },
    {XK_Prior,        Mod1Mask | ControlMask,             "\033[85;7u",  0,  0 },
    {XK_Prior,        Mod1Mask | ControlMask | ShiftMask, "\033[85;8u",  0,  0 },
    {XK_Prior,        Mod1Mask | ShiftMask,               "\033[85;4u",  0,  0 },
    {XK_Next,         XK_NO_MOD,                          "\033[6~",     0,  0 },
    {XK_Next,         ControlMask | ShiftMask,            "\033[86;6u",  0,  0 },
    {XK_Next,         Mod1Mask,                           "\033[86;3u",  0,  0 },
    {XK_Next,         Mod1Mask | ControlMask,             "\033[86;7u",  0,  0 },
    {XK_Next,         Mod1Mask | ControlMask | ShiftMask, "\033[86;8u",  0,  0 },
    {XK_Next,         Mod1Mask | ShiftMask,               "\033[86;4u",  0,  0 },
    {XK_Print,        ControlMask,                        "\033[97;5u",  0,  0 },
    {XK_Print,        ControlMask | ShiftMask,            "\033[97;6u",  0,  0 },
    {XK_Print,        Mod1Mask,                           "\033[97;3u",  0,  0 },
    {XK_Print,        Mod1Mask | ControlMask,             "\033[97;7u",  0,  0 },
    {XK_Print,        Mod1Mask | ControlMask | ShiftMask, "\033[97;8u",  0,  0 },
    {XK_Print,        Mod1Mask | ShiftMask,               "\033[97;4u",  0,  0 },
    {XK_Print,        ShiftMask,                          "\033[97;2u",  0,  0 },
    {XK_Insert,       XK_NO_MOD,                          "\033[4h",     -1, 0 },
    {XK_Insert,       XK_NO_MOD,                          "\033[2~",     +1, 0 },
    {XK_Insert,       ControlMask | ShiftMask,            "\033[99;6u",  0,  0 },
    {XK_Insert,       Mod1Mask,                           "\033[99;3u",  0,  0 },
    {XK_Insert,       Mod1Mask | ControlMask,             "\033[99;7u",  0,  0 },
    {XK_Insert,       Mod1Mask | ControlMask | ShiftMask, "\033[99;8u",  0,  0 },
    {XK_Insert,       Mod1Mask | ShiftMask,               "\033[99;4u",  0,  0 },
    {XK_Menu,         ControlMask,                        "\033[103;5u", 0,  0 },
    {XK_Menu,         ControlMask | ShiftMask,            "\033[103;6u", 0,  0 },
    {XK_Menu,         Mod1Mask,                           "\033[103;3u", 0,  0 },
    {XK_Menu,         Mod1Mask | ControlMask,             "\033[103;7u", 0,  0 },
    {XK_Menu,         Mod1Mask | ControlMask | ShiftMask, "\033[103;8u", 0,  0 },
    {XK_Menu,         Mod1Mask | ShiftMask,               "\033[103;4u", 0,  0 },
    {XK_Menu,         ShiftMask,                          "\033[103;2u", 0,  0 },
    {XK_Delete,       XK_NO_MOD,                          "\033[P",      -1, 0 },
    {XK_Delete,       XK_NO_MOD,                          "\033[3~",     +1, 0 },
    {XK_Delete,       ControlMask | ShiftMask,            "\033[255;6u", 0,  0 },
    {XK_Delete,       Mod1Mask,                           "\033[255;3u", 0,  0 },
    {XK_Delete,       Mod1Mask | ControlMask,             "\033[255;7u", 0,  0 },
    {XK_Delete,       Mod1Mask | ControlMask | ShiftMask, "\033[255;8u", 0,  0 },
    {XK_Delete,       Mod1Mask | ShiftMask,               "\033[255;4u", 0,  0 },
    {XK_i,            ControlMask,                        "\033[105;5u", 0,  0 },
    {XK_i,            Mod1Mask | ControlMask,             "\033[105;7u", 0,  0 },
    {XK_m,            ControlMask,                        "\033[109;5u", 0,  0 },
    {XK_m,            Mod1Mask | ControlMask,             "\033[109;7u", 0,  0 },
    {XK_space,        ControlMask | ShiftMask,            "\033[32;6u",  0,  0 },
    {XK_space,        Mod1Mask,                           "\033[32;3u",  0,  0 },
    {XK_space,        Mod1Mask | ControlMask,             "\033[32;7u",  0,  0 },
    {XK_space,        Mod1Mask | ControlMask | ShiftMask, "\033[32;8u",  0,  0 },
    {XK_space,        Mod1Mask | ShiftMask,               "\033[32;4u",  0,  0 },
    {XK_space,        ShiftMask,                          "\033[32;2u",  0,  0 },
    {XK_0,            ControlMask,                        "\033[48;5u",  0,  0 },
    {XK_A,            ControlMask | ShiftMask,            "\033[65;6u",  0,  0 },
    {XK_B,            ControlMask | ShiftMask,            "\033[66;6u",  0,  0 },
    {XK_C,            ControlMask | ShiftMask,            "\033[67;6u",  0,  0 },
    {XK_D,            ControlMask | ShiftMask,            "\033[68;6u",  0,  0 },
    {XK_E,            ControlMask | ShiftMask,            "\033[69;6u",  0,  0 },
    {XK_F,            ControlMask | ShiftMask,            "\033[70;6u",  0,  0 },
    {XK_G,            ControlMask | ShiftMask,            "\033[71;6u",  0,  0 },
    {XK_H,            ControlMask | ShiftMask,            "\033[72;6u",  0,  0 },
    {XK_I,            ControlMask | ShiftMask,            "\033[73;6u",  0,  0 },
    {XK_I,            Mod1Mask | ControlMask | ShiftMask, "\033[73;8u",  0,  0 },
    {XK_J,            ControlMask | ShiftMask,            "\033[75;6u",  0,  0 },
    {XK_K,            ControlMask | ShiftMask,            "\033[74;6u",  0,  0 },
    {XK_L,            ControlMask | ShiftMask,            "\033[76;6u",  0,  0 },
    {XK_M,            ControlMask | ShiftMask,            "\033[77;6u",  0,  0 },
    {XK_M,            Mod1Mask | ControlMask | ShiftMask, "\033[77;8u",  0,  0 },
    {XK_N,            ControlMask | ShiftMask,            "\033[78;6u",  0,  0 },
    {XK_O,            ControlMask | ShiftMask,            "\033[79;6u",  0,  0 },
    {XK_P,            ControlMask | ShiftMask,            "\033[80;6u",  0,  0 },
    {XK_Q,            ControlMask | ShiftMask,            "\033[81;6u",  0,  0 },
    {XK_R,            ControlMask | ShiftMask,            "\033[82;6u",  0,  0 },
    {XK_S,            ControlMask | ShiftMask,            "\033[83;6u",  0,  0 },
    {XK_T,            ControlMask | ShiftMask,            "\033[84;6u",  0,  0 },
    {XK_U,            ControlMask | ShiftMask,            "\033[85;6u",  0,  0 },
    {XK_V,            ControlMask | ShiftMask,            "\033[86;6u",  0,  0 },
    {XK_W,            ControlMask | ShiftMask,            "\033[87;6u",  0,  0 },
    {XK_X,            ControlMask | ShiftMask,            "\033[88;6u",  0,  0 },
    {XK_Y,            ControlMask | ShiftMask,            "\033[89;6u",  0,  0 },
    {XK_Z,            ControlMask | ShiftMask,            "\033[90;6u",  0,  0 },
    {XK_Z,            ControlMask | ShiftMask,            "\033[90;6u",  0,  0 },
    {XK_0,            Mod1Mask | ControlMask,             "\033[48;7u",  0,  0 },
    {XK_1,            ControlMask,                        "\033[49;5u",  0,  0 },
    {XK_1,            Mod1Mask | ControlMask,             "\033[49;7u",  0,  0 },
    {XK_2,            ControlMask,                        "\033[50;5u",  0,  0 },
    {XK_2,            Mod1Mask | ControlMask,             "\033[50;7u",  0,  0 },
    {XK_3,            ControlMask,                        "\033[51;5u",  0,  0 },
    {XK_3,            Mod1Mask | ControlMask,             "\033[51;7u",  0,  0 },
    {XK_4,            ControlMask,                        "\033[52;5u",  0,  0 },
    {XK_4,            Mod1Mask | ControlMask,             "\033[52;7u",  0,  0 },
    {XK_5,            ControlMask,                        "\033[53;5u",  0,  0 },
    {XK_5,            Mod1Mask | ControlMask,             "\033[53;7u",  0,  0 },
    {XK_6,            ControlMask,                        "\033[54;5u",  0,  0 },
    {XK_6,            Mod1Mask | ControlMask,             "\033[54;7u",  0,  0 },
    {XK_7,            ControlMask,                        "\033[55;5u",  0,  0 },
    {XK_7,            Mod1Mask | ControlMask,             "\033[55;7u",  0,  0 },
    {XK_8,            ControlMask,                        "\033[56;5u",  0,  0 },
    {XK_8,            Mod1Mask | ControlMask,             "\033[56;7u",  0,  0 },
    {XK_9,            ControlMask,                        "\033[57;5u",  0,  0 },
    {XK_9,            Mod1Mask | ControlMask,             "\033[57;7u",  0,  0 },
    {XK_ampersand,    ControlMask,                        "\033[38;5u",  0,  0 },
    {XK_ampersand,    ControlMask | ShiftMask,            "\033[38;6u",  0,  0 },
    {XK_ampersand,    Mod1Mask,                           "\033[38;3u",  0,  0 },
    {XK_ampersand,    Mod1Mask | ControlMask,             "\033[38;7u",  0,  0 },
    {XK_ampersand,    Mod1Mask | ControlMask | ShiftMask, "\033[38;8u",  0,  0 },
    {XK_ampersand,    Mod1Mask | ShiftMask,               "\033[38;4u",  0,  0 },
    {XK_apostrophe,   ControlMask,                        "\033[39;5u",  0,  0 },
    {XK_apostrophe,   ControlMask | ShiftMask,            "\033[39;6u",  0,  0 },
    {XK_apostrophe,   Mod1Mask,                           "\033[39;3u",  0,  0 },
    {XK_apostrophe,   Mod1Mask | ControlMask,             "\033[39;7u",  0,  0 },
    {XK_apostrophe,   Mod1Mask | ControlMask | ShiftMask, "\033[39;8u",  0,  0 },
    {XK_apostrophe,   Mod1Mask | ShiftMask,               "\033[39;4u",  0,  0 },
    {XK_asciicircum,  ControlMask,                        "\033[94;5u",  0,  0 },
    {XK_asciicircum,  ControlMask | ShiftMask,            "\033[94;6u",  0,  0 },
    {XK_asciicircum,  Mod1Mask,                           "\033[94;3u",  0,  0 },
    {XK_asciicircum,  Mod1Mask | ControlMask,             "\033[94;7u",  0,  0 },
    {XK_asciicircum,  Mod1Mask | ControlMask | ShiftMask, "\033[94;8u",  0,  0 },
    {XK_asciicircum,  Mod1Mask | ShiftMask,               "\033[94;4u",  0,  0 },
    {XK_asciitilde,   ControlMask,                        "\033[126;5u", 0,  0 },
    {XK_asciitilde,   ControlMask | ShiftMask,            "\033[126;6u", 0,  0 },
    {XK_asciitilde,   Mod1Mask,                           "\033[126;3u", 0,  0 },
    {XK_asciitilde,   Mod1Mask | ControlMask,             "\033[126;7u", 0,  0 },
    {XK_asciitilde,   Mod1Mask | ControlMask | ShiftMask, "\033[126;8u", 0,  0 },
    {XK_asciitilde,   Mod1Mask | ShiftMask,               "\033[126;4u", 0,  0 },
    {XK_asterisk,     ControlMask,                        "\033[42;5u",  0,  0 },
    {XK_asterisk,     ControlMask | ShiftMask,            "\033[42;6u",  0,  0 },
    {XK_asterisk,     Mod1Mask,                           "\033[42;3u",  0,  0 },
    {XK_asterisk,     Mod1Mask | ControlMask,             "\033[42;7u",  0,  0 },
    {XK_asterisk,     Mod1Mask | ControlMask | ShiftMask, "\033[42;8u",  0,  0 },
    {XK_asterisk,     Mod1Mask | ShiftMask,               "\033[42;4u",  0,  0 },
    {XK_at,           ControlMask,                        "\033[64;5u",  0,  0 },
    {XK_at,           ControlMask | ShiftMask,            "\033[64;6u",  0,  0 },
    {XK_at,           Mod1Mask,                           "\033[64;3u",  0,  0 },
    {XK_at,           Mod1Mask | ControlMask,             "\033[64;7u",  0,  0 },
    {XK_at,           Mod1Mask | ControlMask | ShiftMask, "\033[64;8u",  0,  0 },
    {XK_at,           Mod1Mask | ShiftMask,               "\033[64;4u",  0,  0 },
    {XK_backslash,    ControlMask,                        "\033[92;5u",  0,  0 },
    {XK_backslash,    ControlMask | ShiftMask,            "\033[92;6u",  0,  0 },
    {XK_backslash,    Mod1Mask,                           "\033[92;3u",  0,  0 },
    {XK_backslash,    Mod1Mask | ControlMask,             "\033[92;7u",  0,  0 },
    {XK_backslash,    Mod1Mask | ControlMask | ShiftMask, "\033[92;8u",  0,  0 },
    {XK_backslash,    Mod1Mask | ShiftMask,               "\033[92;4u",  0,  0 },
    {XK_bar,          ControlMask,                        "\033[124;5u", 0,  0 },
    {XK_bar,          ControlMask | ShiftMask,            "\033[124;6u", 0,  0 },
    {XK_bar,          Mod1Mask,                           "\033[124;3u", 0,  0 },
    {XK_bar,          Mod1Mask | ControlMask,             "\033[124;7u", 0,  0 },
    {XK_bar,          Mod1Mask | ControlMask | ShiftMask, "\033[124;8u", 0,  0 },
    {XK_bar,          Mod1Mask | ShiftMask,               "\033[124;4u", 0,  0 },
    {XK_braceleft,    ControlMask,                        "\033[123;5u", 0,  0 },
    {XK_braceleft,    ControlMask | ShiftMask,            "\033[123;6u", 0,  0 },
    {XK_braceleft,    Mod1Mask,                           "\033[123;3u", 0,  0 },
    {XK_braceleft,    Mod1Mask | ControlMask,             "\033[123;7u", 0,  0 },
    {XK_braceleft,    Mod1Mask | ControlMask | ShiftMask, "\033[123;8u", 0,  0 },
    {XK_braceleft,    Mod1Mask | ShiftMask,               "\033[123;4u", 0,  0 },
    {XK_braceright,   ControlMask,                        "\033[125;5u", 0,  0 },
    {XK_braceright,   ControlMask | ShiftMask,            "\033[125;6u", 0,  0 },
    {XK_braceright,   Mod1Mask,                           "\033[125;3u", 0,  0 },
    {XK_braceright,   Mod1Mask | ControlMask,             "\033[125;7u", 0,  0 },
    {XK_braceright,   Mod1Mask | ControlMask | ShiftMask, "\033[125;8u", 0,  0 },
    {XK_braceright,   Mod1Mask | ShiftMask,               "\033[125;4u", 0,  0 },
    {XK_bracketleft,  ControlMask,                        "\033[91;5u",  0,  0 },
    {XK_bracketleft,  ControlMask | ShiftMask,            "\033[91;6u",  0,  0 },
    {XK_bracketleft,  Mod1Mask,                           "\033[91;3u",  0,  0 },
    {XK_bracketleft,  Mod1Mask | ControlMask,             "\033[91;7u",  0,  0 },
    {XK_bracketleft,  Mod1Mask | ControlMask | ShiftMask, "\033[91;8u",  0,  0 },
    {XK_bracketleft,  Mod1Mask | ShiftMask,               "\033[91;4u",  0,  0 },
    {XK_bracketright, ControlMask,                        "\033[93;5u",  0,  0 },
    {XK_bracketright, ControlMask | ShiftMask,            "\033[93;6u",  0,  0 },
    {XK_bracketright, Mod1Mask,                           "\033[93;3u",  0,  0 },
    {XK_bracketright, Mod1Mask | ControlMask,             "\033[93;7u",  0,  0 },
    {XK_bracketright, Mod1Mask | ControlMask | ShiftMask, "\033[93;8u",  0,  0 },
    {XK_bracketright, Mod1Mask | ShiftMask,               "\033[93;4u",  0,  0 },
    {XK_colon,        ControlMask,                        "\033[58;5u",  0,  0 },
    {XK_colon,        ControlMask | ShiftMask,            "\033[58;6u",  0,  0 },
    {XK_colon,        Mod1Mask,                           "\033[58;3u",  0,  0 },
    {XK_colon,        Mod1Mask | ControlMask,             "\033[58;7u",  0,  0 },
    {XK_colon,        Mod1Mask | ControlMask | ShiftMask, "\033[58;8u",  0,  0 },
    {XK_colon,        Mod1Mask | ShiftMask,               "\033[58;4u",  0,  0 },
    {XK_comma,        ControlMask,                        "\033[44;5u",  0,  0 },
    {XK_comma,        ControlMask | ShiftMask,            "\033[44;6u",  0,  0 },
    {XK_comma,        Mod1Mask,                           "\033[44;3u",  0,  0 },
    {XK_comma,        Mod1Mask | ControlMask,             "\033[44;7u",  0,  0 },
    {XK_comma,        Mod1Mask | ControlMask | ShiftMask, "\033[44;8u",  0,  0 },
    {XK_comma,        Mod1Mask | ShiftMask,               "\033[44;4u",  0,  0 },
    {XK_dollar,       ControlMask,                        "\033[36;5u",  0,  0 },
    {XK_dollar,       ControlMask | ShiftMask,            "\033[36;6u",  0,  0 },
    {XK_dollar,       Mod1Mask,                           "\033[36;3u",  0,  0 },
    {XK_dollar,       Mod1Mask | ControlMask,             "\033[36;7u",  0,  0 },
    {XK_dollar,       Mod1Mask | ControlMask | ShiftMask, "\033[36;8u",  0,  0 },
    {XK_dollar,       Mod1Mask | ShiftMask,               "\033[36;4u",  0,  0 },
    {XK_equal,        ControlMask,                        "\033[61;5u",  0,  0 },
    {XK_equal,        ControlMask | ShiftMask,            "\033[61;6u",  0,  0 },
    {XK_equal,        Mod1Mask,                           "\033[61;3u",  0,  0 },
    {XK_equal,        Mod1Mask | ControlMask,             "\033[61;7u",  0,  0 },
    {XK_equal,        Mod1Mask | ControlMask | ShiftMask, "\033[61;8u",  0,  0 },
    {XK_equal,        Mod1Mask | ShiftMask,               "\033[61;4u",  0,  0 },
    {XK_exclam,       ControlMask,                        "\033[33;5u",  0,  0 },
    {XK_exclam,       ControlMask | ShiftMask,            "\033[33;6u",  0,  0 },
    {XK_exclam,       Mod1Mask,                           "\033[33;3u",  0,  0 },
    {XK_exclam,       Mod1Mask | ControlMask,             "\033[33;7u",  0,  0 },
    {XK_exclam,       Mod1Mask | ControlMask | ShiftMask, "\033[33;8u",  0,  0 },
    {XK_exclam,       Mod1Mask | ShiftMask,               "\033[33;4u",  0,  0 },
    {XK_grave,        ControlMask,                        "\033[96;5u",  0,  0 },
    {XK_grave,        ControlMask | ShiftMask,            "\033[96;6u",  0,  0 },
    {XK_grave,        Mod1Mask,                           "\033[96;3u",  0,  0 },
    {XK_grave,        Mod1Mask | ControlMask,             "\033[96;7u",  0,  0 },
    {XK_grave,        Mod1Mask | ControlMask | ShiftMask, "\033[96;8u",  0,  0 },
    {XK_grave,        Mod1Mask | ShiftMask,               "\033[96;4u",  0,  0 },
    {XK_greater,      ControlMask,                        "\033[62;5u",  0,  0 },
    {XK_greater,      ControlMask | ShiftMask,            "\033[62;6u",  0,  0 },
    {XK_greater,      Mod1Mask,                           "\033[62;3u",  0,  0 },
    {XK_greater,      Mod1Mask | ControlMask,             "\033[62;7u",  0,  0 },
    {XK_greater,      Mod1Mask | ControlMask | ShiftMask, "\033[62;8u",  0,  0 },
    {XK_greater,      Mod1Mask | ShiftMask,               "\033[62;4u",  0,  0 },
    {XK_less,         ControlMask,                        "\033[60;5u",  0,  0 },
    {XK_less,         ControlMask | ShiftMask,            "\033[60;6u",  0,  0 },
    {XK_less,         Mod1Mask,                           "\033[60;3u",  0,  0 },
    {XK_less,         Mod1Mask | ControlMask,             "\033[60;7u",  0,  0 },
    {XK_less,         Mod1Mask | ControlMask | ShiftMask, "\033[60;8u",  0,  0 },
    {XK_less,         Mod1Mask | ShiftMask,               "\033[60;4u",  0,  0 },
    {XK_minus,        ControlMask,                        "\033[45;5u",  0,  0 },
    {XK_minus,        ControlMask | ShiftMask,            "\033[45;6u",  0,  0 },
    {XK_minus,        Mod1Mask,                           "\033[45;3u",  0,  0 },
    {XK_minus,        Mod1Mask | ControlMask,             "\033[45;7u",  0,  0 },
    {XK_minus,        Mod1Mask | ControlMask | ShiftMask, "\033[45;8u",  0,  0 },
    {XK_minus,        Mod1Mask | ShiftMask,               "\033[45;4u",  0,  0 },
    {XK_numbersign,   ControlMask,                        "\033[35;5u",  0,  0 },
    {XK_numbersign,   ControlMask | ShiftMask,            "\033[35;6u",  0,  0 },
    {XK_numbersign,   Mod1Mask,                           "\033[35;3u",  0,  0 },
    {XK_numbersign,   Mod1Mask | ControlMask,             "\033[35;7u",  0,  0 },
    {XK_numbersign,   Mod1Mask | ControlMask | ShiftMask, "\033[35;8u",  0,  0 },
    {XK_numbersign,   Mod1Mask | ShiftMask,               "\033[35;4u",  0,  0 },
    {XK_parenleft,    ControlMask,                        "\033[40;5u",  0,  0 },
    {XK_parenleft,    ControlMask | ShiftMask,            "\033[40;6u",  0,  0 },
    {XK_parenleft,    Mod1Mask,                           "\033[40;3u",  0,  0 },
    {XK_parenleft,    Mod1Mask | ControlMask,             "\033[40;7u",  0,  0 },
    {XK_parenleft,    Mod1Mask | ControlMask | ShiftMask, "\033[40;8u",  0,  0 },
    {XK_parenleft,    Mod1Mask | ShiftMask,               "\033[40;4u",  0,  0 },
    {XK_parenright,   ControlMask,                        "\033[41;5u",  0,  0 },
    {XK_parenright,   ControlMask | ShiftMask,            "\033[41;6u",  0,  0 },
    {XK_parenright,   Mod1Mask,                           "\033[41;3u",  0,  0 },
    {XK_parenright,   Mod1Mask | ControlMask,             "\033[41;7u",  0,  0 },
    {XK_parenright,   Mod1Mask | ControlMask | ShiftMask, "\033[41;8u",  0,  0 },
    {XK_parenright,   Mod1Mask | ShiftMask,               "\033[41;4u",  0,  0 },
    {XK_percent,      ControlMask,                        "\033[37;5u",  0,  0 },
    {XK_percent,      ControlMask | ShiftMask,            "\033[37;6u",  0,  0 },
    {XK_percent,      Mod1Mask,                           "\033[37;3u",  0,  0 },
    {XK_percent,      Mod1Mask | ControlMask,             "\033[37;7u",  0,  0 },
    {XK_percent,      Mod1Mask | ControlMask | ShiftMask, "\033[37;8u",  0,  0 },
    {XK_percent,      Mod1Mask | ShiftMask,               "\033[37;4u",  0,  0 },
    {XK_period,       ControlMask,                        "\033[46;5u",  0,  0 },
    {XK_period,       ControlMask | ShiftMask,            "\033[46;6u",  0,  0 },
    {XK_period,       Mod1Mask | ControlMask,             "\033[46;7u",  0,  0 },
    {XK_period,       Mod1Mask | ControlMask | ShiftMask, "\033[46;8u",  0,  0 },
    {XK_period,       Mod1Mask | ShiftMask,               "\033[46;4u",  0,  0 },
    {XK_plus,         ControlMask,                        "\033[43;5u",  0,  0 },
    {XK_plus,         ControlMask | ShiftMask,            "\033[43;6u",  0,  0 },
    {XK_plus,         Mod1Mask,                           "\033[43;3u",  0,  0 },
    {XK_plus,         Mod1Mask | ControlMask,             "\033[43;7u",  0,  0 },
    {XK_plus,         Mod1Mask | ControlMask | ShiftMask, "\033[43;8u",  0,  0 },
    {XK_plus,         Mod1Mask | ShiftMask,               "\033[43;4u",  0,  0 },
    {XK_question,     ControlMask,                        "\033[63;5u",  0,  0 },
    {XK_question,     ControlMask | ShiftMask,            "\033[63;6u",  0,  0 },
    {XK_question,     Mod1Mask,                           "\033[63;3u",  0,  0 },
    {XK_question,     Mod1Mask | ControlMask,             "\033[63;7u",  0,  0 },
    {XK_question,     Mod1Mask | ControlMask | ShiftMask, "\033[63;8u",  0,  0 },
    {XK_question,     Mod1Mask | ShiftMask,               "\033[63;4u",  0,  0 },
    {XK_quotedbl,     ControlMask,                        "\033[34;5u",  0,  0 },
    {XK_quotedbl,     ControlMask | ShiftMask,            "\033[34;6u",  0,  0 },
    {XK_quotedbl,     Mod1Mask,                           "\033[34;3u",  0,  0 },
    {XK_quotedbl,     Mod1Mask | ControlMask,             "\033[34;7u",  0,  0 },
    {XK_quotedbl,     Mod1Mask | ControlMask | ShiftMask, "\033[34;8u",  0,  0 },
    {XK_quotedbl,     Mod1Mask | ShiftMask,               "\033[34;4u",  0,  0 },
    {XK_semicolon,    ControlMask,                        "\033[59;5u",  0,  0 },
    {XK_semicolon,    ControlMask | ShiftMask,            "\033[59;6u",  0,  0 },
    {XK_semicolon,    Mod1Mask,                           "\033[59;3u",  0,  0 },
    {XK_semicolon,    Mod1Mask | ControlMask,             "\033[59;7u",  0,  0 },
    {XK_semicolon,    Mod1Mask | ControlMask | ShiftMask, "\033[59;8u",  0,  0 },
    {XK_semicolon,    Mod1Mask | ShiftMask,               "\033[59;4u",  0,  0 },
    {XK_slash,        ControlMask | ShiftMask,            "\033[47;6u",  0,  0 },
    {XK_slash,        Mod1Mask,                           "\033[47;3u",  0,  0 },
    {XK_slash,        Mod1Mask | ControlMask,             "\033[47;7u",  0,  0 },
    {XK_slash,        Mod1Mask | ControlMask | ShiftMask, "\033[47;8u",  0,  0 },
    {XK_slash,        Mod1Mask | ShiftMask,               "\033[47;4u",  0,  0 },
    {XK_underscore,   ControlMask,                        "\033[95;5u",  0,  0 },
    {XK_underscore,   ControlMask | ShiftMask,            "\033[95;6u",  0,  0 },
    {XK_underscore,   Mod1Mask,                           "\033[95;3u",  0,  0 },
    {XK_underscore,   Mod1Mask | ControlMask,             "\033[95;7u",  0,  0 },
    {XK_underscore,   Mod1Mask | ControlMask | ShiftMask, "\033[95;8u",  0,  0 },
    {XK_underscore,   Mod1Mask | ShiftMask,               "\033[95;4u",  0,  0 },
};

/*
 * Selection types' masks.
 * Use the same masks as usual.
 * Button1Mask is always unset, to make masks match between ButtonPress.
 * ButtonRelease and MotionNotify.
 * If no match is found, regular selection is used.
 */
static uint selmasks[] = {
    [SEL_RECTANGULAR] = Mod1Mask,
};

/*
 * Printable characters in ASCII, used to estimate the advance width
 * of single wide characters.
 */
static char ascii_printable[] = " !\"#$%&'()*+,-./0123456789:;<=>?"
                                "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
                                "`abcdefghijklmnopqrstuvwxyz{|}~";

/* XEMBED messages */
#define XEMBED_FOCUS_IN  4
#define XEMBED_FOCUS_OUT 5

/* macros */
#define IS_SET(flag) ((win.mode & (flag)) != 0)
#define TRUERED(x)   (((x) & 0xff0000) >> 8)
#define TRUEGREEN(x) (((x) & 0xff00))
#define TRUEBLUE(x)  (((x) & 0xff) << 8)

typedef XftDraw *Draw;
typedef XftColor Color;
typedef XftGlyphFontSpec GlyphFontSpec;

/* Purely graphic info */
typedef struct {
    int tw, th; /* tty width and height */
    int w, h;   /* window width and height */
    int hborderpx, vborderpx;
    int ch;     /* char height */
    int cw;     /* char width  */
    int mode;   /* window state/mode flags */
    int cursor; /* cursor style */
} TermWindow;

typedef struct {
    Display *dpy;
    Colormap cmap;
    Window win;
    Drawable buf;
    GlyphFontSpec *specbuf; /* font spec buffer used for rendering */
    Atom xembed, wmdeletewin, netwmname, netwmiconname, netwmpid;
    struct {
        XIM xim;
        XIC xic;
        XPoint spot;
        XVaNestedList spotlist;
    } ime;
    Draw draw;
    Visual *vis;
    XSetWindowAttributes attrs;
    int scr;
    int isfixed; /* is fixed geometry? */
    int depth;   /* bit depth */
    int l, t;    /* left and top offset */
    int gm;      /* geometry mask */
} XWindow;

typedef struct {
    Atom xtarget;
    char *primary, *clipboard;
    struct timespec tclick1;
    struct timespec tclick2;
} XSelection;

/* Font structure */
#define Font Font_
typedef struct {
    int height;
    int width;
    int ascent;
    int descent;
    int badslant;
    int badweight;
    short lbearing;
    short rbearing;
    XftFont *match;
    FcFontSet *set;
    FcPattern *pattern;
} Font;

/* Drawing Context */
typedef struct {
    Color *col;
    size_t collen;
    Font font, bfont, ifont, ibfont;
    GC gc;
} DC;

static inline ushort sixd_to_16bit(int);
static int xmakeglyphfontspecs(XftGlyphFontSpec *, const Glyph *, int, int, int);
static void xdrawglyphfontspecs(const XftGlyphFontSpec *, Glyph, int, int, int, int);
static void xdrawglyph(Glyph, int, int);
static void xclear(int, int, int, int);
static int xgeommasktogravity(int);
static int ximopen(Display *);
static void ximinstantiate(Display *, XPointer, XPointer);
static void ximdestroy(XIM, XPointer, XPointer);
static int xicdestroy(XIC, XPointer, XPointer);
static void xinit(int, int);
static void cresize(int, int);
static void xresize(int, int);
static void xhints(void);
static int xloadcolor(int, const char *, Color *);
static int xloadfont(Font *, FcPattern *);
static void xloadfonts(const char *, double);
static void xunloadfont(Font *);
static void xunloadfonts(void);
static void xsetenv(void);
static void xseturgency(int);
static int evcol(XEvent *);
static int evrow(XEvent *);

static void expose(XEvent *);
static void visibility(XEvent *);
static void unmap(XEvent *);
static void kpress(XEvent *);
static void cmessage(XEvent *);
static void resize(XEvent *);
static void focus(XEvent *);
static uint buttonmask(uint);
static int mouseaction(XEvent *, uint);
static void brelease(XEvent *);
static void bpress(XEvent *);
static void bmotion(XEvent *);
static void propnotify(XEvent *);
static void selnotify(XEvent *);
static void selclear_(XEvent *);
static void selrequest(XEvent *);
static void setsel(char *, Time);
static void mousesel(XEvent *, int);
static void mousereport(XEvent *);
static char *kmap(KeySym, uint);
static int match(uint, uint);

static void run(void);
static void usage(void);

static void (*handler[LASTEvent])(XEvent *) = {
    [KeyPress]         = kpress,
    [ClientMessage]    = cmessage,
    [ConfigureNotify]  = resize,
    [VisibilityNotify] = visibility,
    [UnmapNotify]      = unmap,
    [Expose]           = expose,
    [FocusIn]          = focus,
    [FocusOut]         = focus,
    [MotionNotify]     = bmotion,
    [ButtonPress]      = bpress,
    [ButtonRelease]    = brelease,
    /*
     * Uncomment if you want the selection to disappear when you select something
     * different in another window.
     */
    /*	[SelectionClear] = selclear_, */
    [SelectionNotify] = selnotify,
    /*
     * PropertyNotify is only turned on when there is some INCR transfer happening
     * for the selection retrieval.
     */
    [PropertyNotify]   = propnotify,
    [SelectionRequest] = selrequest,
};

/* Globals */
static DC dc;
static XWindow xw;
static XSelection xsel;
static TermWindow win;

/* Font Ring Cache */
enum { FRC_NORMAL, FRC_ITALIC, FRC_BOLD, FRC_ITALICBOLD };

typedef struct {
    XftFont *font;
    int flags;
    Rune unicodep;
} Fontcache;

/* Fontcache is an array now. A new font will be appended to the array. */
static Fontcache *frc         = NULL;
static int frclen             = 0;
static int frccap             = 0;
static char *usedfont         = NULL;
static double usedfontsize    = 0;
static double defaultfontsize = 0;

static char *opt_alpha = NULL;
static char *opt_class = NULL;
static char **opt_cmd  = NULL;
static char *opt_embed = NULL;
static char *opt_font  = NULL;
static char *opt_io    = NULL;
static char *opt_line  = NULL;
static char *opt_name  = NULL;
static char *opt_title = NULL;

static uint buttons; /* bit field of pressed buttons */

void clipcopy(const Arg *dummy) {
    Atom clipboard;

    free(xsel.clipboard);
    xsel.clipboard = NULL;

    if (xsel.primary != NULL) {
        xsel.clipboard = xstrdup(xsel.primary);
        clipboard      = XInternAtom(xw.dpy, "CLIPBOARD", 0);
        XSetSelectionOwner(xw.dpy, clipboard, xw.win, CurrentTime);
    }
}

void clippaste(const Arg *dummy) {
    Atom clipboard;

    clipboard = XInternAtom(xw.dpy, "CLIPBOARD", 0);
    XConvertSelection(xw.dpy, clipboard, xsel.xtarget, clipboard, xw.win, CurrentTime);
}

void selpaste(const Arg *dummy) {
    XConvertSelection(xw.dpy, XA_PRIMARY, xsel.xtarget, XA_PRIMARY, xw.win, CurrentTime);
}

void numlock(const Arg *dummy) {
    win.mode ^= MODE_NUMLOCK;
}

void zoom(const Arg *arg) {
    Arg larg;

    larg.f = usedfontsize + arg->f;
    zoomabs(&larg);
}

void zoomabs(const Arg *arg) {
    xunloadfonts();
    xloadfonts(usedfont, arg->f);
    cresize(0, 0);
    redraw();
    xhints();
}

void zoomreset(const Arg *arg) {
    Arg larg;

    if (defaultfontsize > 0) {
        larg.f = defaultfontsize;
        zoomabs(&larg);
    }
}

void ttysend(const Arg *arg) {
    ttywrite(arg->s, strlen(arg->s), 1);
}

int evcol(XEvent *e) {
    int x = e->xbutton.x - win.hborderpx;
    LIMIT(x, 0, win.tw - 1);
    return x / win.cw;
}

int evrow(XEvent *e) {
    int y = e->xbutton.y - win.vborderpx;
    LIMIT(y, 0, win.th - 1);
    return y / win.ch;
}

void mousesel(XEvent *e, int done) {
    int type, seltype = SEL_REGULAR;
    uint state = e->xbutton.state & ~(Button1Mask | forcemousemod);

    for (type = 1; type < LEN(selmasks); ++type) {
        if (match(selmasks[type], state)) {
            seltype = type;
            break;
        }
    }
    selextend(evcol(e), evrow(e), seltype, done);
    if (done)
        setsel(getsel(), e->xbutton.time);
}

void mousereport(XEvent *e) {
    int len, btn, code;
    int x = evcol(e), y = evrow(e);
    int state = e->xbutton.state;
    char buf[40];
    static int ox, oy;

    if (e->type == MotionNotify) {
        if (x == ox && y == oy)
            return;
        if (!IS_SET(MODE_MOUSEMOTION) && !IS_SET(MODE_MOUSEMANY))
            return;
        /* MODE_MOUSEMOTION: no reporting if no button is pressed */
        if (IS_SET(MODE_MOUSEMOTION) && buttons == 0)
            return;
        /* Set btn to lowest-numbered pressed button, or 12 if no
         * buttons are pressed. */
        for (btn = 1; btn <= 11 && !(buttons & (1 << (btn - 1))); btn++)
            ;
        code = 32;
    } else {
        btn = e->xbutton.button;
        /* Only buttons 1 through 11 can be encoded */
        if (btn < 1 || btn > 11)
            return;
        if (e->type == ButtonRelease) {
            /* MODE_MOUSEX10: no button release reporting */
            if (IS_SET(MODE_MOUSEX10))
                return;
            /* Don't send release events for the scroll wheel */
            if (btn == 4 || btn == 5)
                return;
        }
        code = 0;
    }

    ox = x;
    oy = y;

    /* Encode btn into code. If no button is pressed for a motion event in
     * MODE_MOUSEMANY, then encode it as a release. */
    if ((!IS_SET(MODE_MOUSESGR) && e->type == ButtonRelease) || btn == 12)
        code += 3;
    else if (btn >= 8)
        code += 128 + btn - 8;
    else if (btn >= 4)
        code += 64 + btn - 4;
    else
        code += btn - 1;

    if (!IS_SET(MODE_MOUSEX10)) {
        code += ((state & ShiftMask) ? 4 : 0) + ((state & Mod1Mask) ? 8 : 0) /* meta key: alt */
                + ((state & ControlMask) ? 16 : 0);
    }

    if (IS_SET(MODE_MOUSESGR)) {
        len = snprintf(buf, sizeof(buf), "\033[<%d;%d;%d%c", code, x + 1, y + 1, e->type == ButtonRelease ? 'm' : 'M');
    } else if (x < 223 && y < 223) {
        len = snprintf(buf, sizeof(buf), "\033[M%c%c%c", 32 + code, 32 + x + 1, 32 + y + 1);
    } else {
        return;
    }

    ttywrite(buf, len, 0);
}

uint buttonmask(uint button) {
    return button == Button1   ? Button1Mask
           : button == Button2 ? Button2Mask
           : button == Button3 ? Button3Mask
           : button == Button4 ? Button4Mask
           : button == Button5 ? Button5Mask
                               : 0;
}

int mouseaction(XEvent *e, uint release) {
    MouseShortcut *ms;

    /* ignore Button<N>mask for Button<N> - it's set on release */
    uint state = e->xbutton.state & ~buttonmask(e->xbutton.button);

    for (ms = mshortcuts; ms < mshortcuts + LEN(mshortcuts); ms++) {
        if (ms->release == release && ms->button == e->xbutton.button &&
            (match(ms->mod, state) || /* exact or forced */
             match(ms->mod, state & ~forcemousemod))) {
            ms->func(&(ms->arg));
            return 1;
        }
    }

    return 0;
}

void bpress(XEvent *e) {
    int btn = e->xbutton.button;
    struct timespec now;
    int snap;

    if (1 <= btn && btn <= 11)
        buttons |= 1 << (btn - 1);

    if (IS_SET(MODE_MOUSE) && !(e->xbutton.state & forcemousemod)) {
        mousereport(e);
        return;
    }

    if (mouseaction(e, 0))
        return;

    if (btn == Button1) {
        /*
         * If the user clicks below predefined timeouts specific
         * snapping behaviour is exposed.
         */
        clock_gettime(CLOCK_MONOTONIC, &now);
        if (TIMEDIFF(now, xsel.tclick2) <= tripleclicktimeout) {
            snap = SNAP_LINE;
        } else if (TIMEDIFF(now, xsel.tclick1) <= doubleclicktimeout) {
            snap = SNAP_WORD;
        } else {
            snap = 0;
        }
        xsel.tclick2 = xsel.tclick1;
        xsel.tclick1 = now;

        selstart(evcol(e), evrow(e), snap);
    }
}

void propnotify(XEvent *e) {
    XPropertyEvent *xpev;
    Atom clipboard = XInternAtom(xw.dpy, "CLIPBOARD", 0);

    xpev = &e->xproperty;
    if (xpev->state == PropertyNewValue && (xpev->atom == XA_PRIMARY || xpev->atom == clipboard)) {
        selnotify(e);
    }
}

void selnotify(XEvent *e) {
    ulong nitems, ofs, rem;
    int format;
    uchar *data, *last, *repl;
    Atom type, incratom, property = None;

    incratom = XInternAtom(xw.dpy, "INCR", 0);

    ofs = 0;
    if (e->type == SelectionNotify)
        property = e->xselection.property;
    else if (e->type == PropertyNotify)
        property = e->xproperty.atom;

    if (property == None)
        return;

    do {
        if (XGetWindowProperty(xw.dpy, xw.win, property, ofs, BUFSIZ / 4, False, AnyPropertyType, &type, &format, &nitems, &rem, &data)) {
            fprintf(stderr, "Clipboard allocation failed\n");
            return;
        }

        if (e->type == PropertyNotify && nitems == 0 && rem == 0) {
            /*
             * If there is some PropertyNotify with no data, then
             * this is the signal of the selection owner that all
             * data has been transferred. We won't need to receive
             * PropertyNotify events anymore.
             */
            MODBIT(xw.attrs.event_mask, 0, PropertyChangeMask);
            XChangeWindowAttributes(xw.dpy, xw.win, CWEventMask, &xw.attrs);
        }

        if (type == incratom) {
            /*
             * Activate the PropertyNotify events so we receive
             * when the selection owner does send us the next
             * chunk of data.
             */
            MODBIT(xw.attrs.event_mask, 1, PropertyChangeMask);
            XChangeWindowAttributes(xw.dpy, xw.win, CWEventMask, &xw.attrs);

            /*
             * Deleting the property is the transfer start signal.
             */
            XDeleteProperty(xw.dpy, xw.win, (int) property);
            continue;
        }

        /*
         * As seen in getsel:
         * Line endings are inconsistent in the terminal and GUI world
         * copy and pasting. When receiving some selection data,
         * replace all '\n' with '\r'.
         * FIXME: Fix the computer world.
         */
        repl = data;
        last = data + nitems * format / 8;
        while ((repl = memchr(repl, '\n', last - repl))) {
            *repl++ = '\r';
        }

        if (IS_SET(MODE_BRCKTPASTE) && ofs == 0)
            ttywrite("\033[200~", 6, 0);
        ttywrite((char *) data, nitems * format / 8, 1);
        if (IS_SET(MODE_BRCKTPASTE) && rem == 0)
            ttywrite("\033[201~", 6, 0);
        XFree(data);
        /* number of 32-bit chunks returned */
        ofs += nitems * format / 32;
    } while (rem > 0);

    /*
     * Deleting the property again tells the selection owner to send the
     * next data chunk in the property.
     */
    XDeleteProperty(xw.dpy, xw.win, (int) property);
}

void xclipcopy(void) {
    clipcopy(NULL);
}

void selclear_(XEvent *e) {
    selclear();
}

void selrequest(XEvent *e) {
    XSelectionRequestEvent *xsre;
    XSelectionEvent xev;
    Atom xa_targets, string, clipboard;
    char *seltext;

    xsre          = (XSelectionRequestEvent *) e;
    xev.type      = SelectionNotify;
    xev.requestor = xsre->requestor;
    xev.selection = xsre->selection;
    xev.target    = xsre->target;
    xev.time      = xsre->time;
    if (xsre->property == None)
        xsre->property = xsre->target;

    /* reject */
    xev.property = None;

    xa_targets = XInternAtom(xw.dpy, "TARGETS", 0);
    if (xsre->target == xa_targets) {
        /* respond with the supported type */
        string = xsel.xtarget;
        XChangeProperty(xsre->display, xsre->requestor, xsre->property, XA_ATOM, 32, PropModeReplace, (uchar *) &string, 1);
        xev.property = xsre->property;
    } else if (xsre->target == xsel.xtarget || xsre->target == XA_STRING) {
        /*
         * xith XA_STRING non ascii characters may be incorrect in the
         * requestor. It is not our problem, use utf8.
         */
        clipboard = XInternAtom(xw.dpy, "CLIPBOARD", 0);
        if (xsre->selection == XA_PRIMARY) {
            seltext = xsel.primary;
        } else if (xsre->selection == clipboard) {
            seltext = xsel.clipboard;
        } else {
            fprintf(stderr, "Unhandled clipboard selection 0x%lx\n", xsre->selection);
            return;
        }
        if (seltext != NULL) {
            XChangeProperty(xsre->display, xsre->requestor, xsre->property, xsre->target, 8, PropModeReplace, (uchar *) seltext, strlen(seltext));
            xev.property = xsre->property;
        }
    }

    /* all done, send a notification to the listener */
    if (!XSendEvent(xsre->display, xsre->requestor, 1, 0, (XEvent *) &xev))
        fprintf(stderr, "Error sending SelectionNotify event\n");
}

void setsel(char *str, Time t) {
    if (!str)
        return;

    free(xsel.primary);
    xsel.primary = str;

    XSetSelectionOwner(xw.dpy, XA_PRIMARY, xw.win, t);
    if (XGetSelectionOwner(xw.dpy, XA_PRIMARY) != xw.win)
        selclear();
}

void xsetsel(char *str) {
    setsel(str, CurrentTime);
}

void brelease(XEvent *e) {
    int btn = e->xbutton.button;

    if (1 <= btn && btn <= 11)
        buttons &= ~(1 << (btn - 1));

    if (IS_SET(MODE_MOUSE) && !(e->xbutton.state & forcemousemod)) {
        mousereport(e);
        return;
    }

    if (mouseaction(e, 1))
        return;
    if (btn == Button1)
        mousesel(e, 1);
}

void bmotion(XEvent *e) {
    if (IS_SET(MODE_MOUSE) && !(e->xbutton.state & forcemousemod)) {
        mousereport(e);
        return;
    }

    mousesel(e, 0);
}

void cresize(int width, int height) {
    int col, row;

    if (width != 0)
        win.w = width;
    if (height != 0)
        win.h = height;

    col = (win.w - 2 * borderpx) / win.cw;
    row = (win.h - 2 * borderpx) / win.ch;
    col = MAX(1, col);
    row = MAX(1, row);

    win.hborderpx = (win.w - col * win.cw) / 2;
    win.vborderpx = (win.h - row * win.ch) / 2;

    tresize(col, row);
    xresize(col, row);
    ttyresize(win.tw, win.th);
}

void xresize(int col, int row) {
    win.tw = col * win.cw;
    win.th = row * win.ch;

    XFreePixmap(xw.dpy, xw.buf);
    xw.buf = XCreatePixmap(xw.dpy, xw.win, win.w, win.h, xw.depth);
    XftDrawChange(xw.draw, xw.buf);
    xclear(0, 0, win.w, win.h);

    /* resize to new width */
    xw.specbuf = xrealloc(xw.specbuf, col * sizeof(GlyphFontSpec));
}

ushort sixd_to_16bit(int x) {
    return x == 0 ? 0 : 0x3737 + 0x2828 * x;
}

int xloadcolor(int i, const char *name, Color *ncolor) {
    XRenderColor color = {.alpha = 0xffff};

    if (!name) {
        if (BETWEEN(i, 16, 255)) {    /* 256 color */
            if (i < 6 * 6 * 6 + 16) { /* same colors as xterm */
                color.red   = sixd_to_16bit(((i - 16) / 36) % 6);
                color.green = sixd_to_16bit(((i - 16) / 6) % 6);
                color.blue  = sixd_to_16bit(((i - 16) / 1) % 6);
            } else { /* greyscale */
                color.red   = 0x0808 + 0x0a0a * (i - (6 * 6 * 6 + 16));
                color.green = color.blue = color.red;
            }
            return XftColorAllocValue(xw.dpy, xw.vis, xw.cmap, &color, ncolor);
        } else
            name = colorname[i];
    }

    return XftColorAllocName(xw.dpy, xw.vis, xw.cmap, name, ncolor);
}

void xloadcols(void) {
    int i;
    static int loaded;
    Color *cp;

    if (loaded) {
        for (cp = dc.col; cp < &dc.col[dc.collen]; ++cp)
            XftColorFree(xw.dpy, xw.vis, xw.cmap, cp);
    } else {
        dc.collen = MAX(LEN(colorname), 256);
        dc.col    = xmalloc(dc.collen * sizeof(Color));
    }

    for (i = 0; i < dc.collen; i++)
        if (!xloadcolor(i, NULL, &dc.col[i])) {
            if (colorname[i])
                die("could not allocate color '%s'\n", colorname[i]);
            else
                die("could not allocate color %d\n", i);
        }

    /* set alpha value of bg color */
    if (opt_alpha)
        alpha = strtof(opt_alpha, NULL);
    dc.col[defaultbg].color.alpha = (unsigned short) (0xffff * alpha);
    dc.col[defaultbg].pixel &= 0x00FFFFFF;
    dc.col[defaultbg].pixel |= (unsigned char) (0xff * alpha) << 24;
    loaded = 1;
}

int xgetcolor(int x, unsigned char *r, unsigned char *g, unsigned char *b) {
    if (!BETWEEN(x, 0, dc.collen))
        return 1;

    *r = dc.col[x].color.red >> 8;
    *g = dc.col[x].color.green >> 8;
    *b = dc.col[x].color.blue >> 8;

    return 0;
}

int xsetcolorname(int x, const char *name) {
    Color ncolor;

    if (!BETWEEN(x, 0, dc.collen))
        return 1;

    if (!xloadcolor(x, name, &ncolor))
        return 1;

    XftColorFree(xw.dpy, xw.vis, xw.cmap, &dc.col[x]);
    dc.col[x] = ncolor;

    return 0;
}

/*
 * Absolute coordinates.
 */
void xclear(int x1, int y1, int x2, int y2) {
    XftDrawRect(xw.draw, &dc.col[IS_SET(MODE_REVERSE) ? defaultfg : defaultbg], x1, y1, x2 - x1, y2 - y1);
}

void xhints(void) {
    XClassHint class = {opt_name ? opt_name : termname, opt_class ? opt_class : termname};
    XWMHints wm      = {.flags = InputHint, .input = 1};
    XSizeHints *sizeh;

    sizeh = XAllocSizeHints();

    sizeh->flags       = PSize | PResizeInc | PBaseSize | PMinSize;
    sizeh->height      = win.h;
    sizeh->width       = win.w;
    sizeh->height_inc  = 1;
    sizeh->width_inc   = 1;
    sizeh->base_height = 2 * borderpx;
    sizeh->base_width  = 2 * borderpx;
    sizeh->min_height  = win.ch + 2 * borderpx;
    sizeh->min_width   = win.cw + 2 * borderpx;
    if (xw.isfixed) {
        sizeh->flags |= PMaxSize;
        sizeh->min_width = sizeh->max_width = win.w;
        sizeh->min_height = sizeh->max_height = win.h;
    }
    if (xw.gm & (XValue | YValue)) {
        sizeh->flags |= USPosition | PWinGravity;
        sizeh->x           = xw.l;
        sizeh->y           = xw.t;
        sizeh->win_gravity = xgeommasktogravity(xw.gm);
    }

    XSetWMProperties(xw.dpy, xw.win, NULL, NULL, NULL, 0, sizeh, &wm, &class);
    XFree(sizeh);
}

int xgeommasktogravity(int mask) {
    switch (mask & (XNegative | YNegative)) {
        case 0:
            return NorthWestGravity;
        case XNegative:
            return NorthEastGravity;
        case YNegative:
            return SouthWestGravity;
    }

    return SouthEastGravity;
}

int xloadfont(Font *f, FcPattern *pattern) {
    FcPattern *configured;
    FcPattern *match;
    FcResult result;
    XGlyphInfo extents;
    int wantattr, haveattr;

    /*
     * Manually configure instead of calling XftMatchFont
     * so that we can use the configured pattern for
     * "missing glyph" lookups.
     */
    configured = FcPatternDuplicate(pattern);
    if (!configured)
        return 1;

    FcConfigSubstitute(NULL, configured, FcMatchPattern);
    XftDefaultSubstitute(xw.dpy, xw.scr, configured);

    match = FcFontMatch(NULL, configured, &result);
    if (!match) {
        FcPatternDestroy(configured);
        return 1;
    }

    if (!(f->match = XftFontOpenPattern(xw.dpy, match))) {
        FcPatternDestroy(configured);
        FcPatternDestroy(match);
        return 1;
    }

    if ((XftPatternGetInteger(pattern, "slant", 0, &wantattr) == XftResultMatch)) {
        /*
         * Check if xft was unable to find a font with the appropriate
         * slant but gave us one anyway. Try to mitigate.
         */
        if ((XftPatternGetInteger(f->match->pattern, "slant", 0, &haveattr) != XftResultMatch) || haveattr < wantattr) {
            f->badslant = 1;
            fputs("font slant does not match\n", stderr);
        }
    }

    if ((XftPatternGetInteger(pattern, "weight", 0, &wantattr) == XftResultMatch)) {
        if ((XftPatternGetInteger(f->match->pattern, "weight", 0, &haveattr) != XftResultMatch) || haveattr != wantattr) {
            f->badweight = 1;
            fputs("font weight does not match\n", stderr);
        }
    }

    XftTextExtentsUtf8(xw.dpy, f->match, (const FcChar8 *) ascii_printable, strlen(ascii_printable), &extents);

    f->set     = NULL;
    f->pattern = configured;

    f->ascent   = f->match->ascent;
    f->descent  = f->match->descent;
    f->lbearing = 0;
    f->rbearing = f->match->max_advance_width;

    f->height = f->ascent + f->descent;
    f->width  = DIVCEIL(extents.xOff, strlen(ascii_printable));

    return 0;
}

void xloadfonts(const char *fontstr, double fontsize) {
    FcPattern *pattern;
    double fontval;

    if (fontstr[0] == '-')
        pattern = XftXlfdParse(fontstr, False, False);
    else
        pattern = FcNameParse((const FcChar8 *) fontstr);

    if (!pattern)
        die("can't open font %s\n", fontstr);

    if (fontsize > 1) {
        FcPatternDel(pattern, FC_PIXEL_SIZE);
        FcPatternDel(pattern, FC_SIZE);
        FcPatternAddDouble(pattern, FC_PIXEL_SIZE, (double) fontsize);
        usedfontsize = fontsize;
    } else {
        if (FcPatternGetDouble(pattern, FC_PIXEL_SIZE, 0, &fontval) == FcResultMatch) {
            usedfontsize = fontval;
        } else if (FcPatternGetDouble(pattern, FC_SIZE, 0, &fontval) == FcResultMatch) {
            usedfontsize = -1;
        } else {
            /*
             * Default font size is 12, if none given. This is to
             * have a known usedfontsize value.
             */
            FcPatternAddDouble(pattern, FC_PIXEL_SIZE, 12);
            usedfontsize = 12;
        }
        defaultfontsize = usedfontsize;
    }

    if (xloadfont(&dc.font, pattern))
        die("can't open font %s\n", fontstr);

    if (usedfontsize < 0) {
        FcPatternGetDouble(dc.font.match->pattern, FC_PIXEL_SIZE, 0, &fontval);
        usedfontsize = fontval;
        if (fontsize == 0)
            defaultfontsize = fontval;
    }

    /* Setting character width and height. */
    win.cw = ceilf(dc.font.width * cwscale);
    win.ch = ceilf(dc.font.height * chscale);

    FcPatternDel(pattern, FC_SLANT);
    FcPatternAddInteger(pattern, FC_SLANT, FC_SLANT_ITALIC);
    if (xloadfont(&dc.ifont, pattern))
        die("can't open font %s\n", fontstr);

    FcPatternDel(pattern, FC_WEIGHT);
    FcPatternAddInteger(pattern, FC_WEIGHT, FC_WEIGHT_BOLD);
    if (xloadfont(&dc.ibfont, pattern))
        die("can't open font %s\n", fontstr);

    FcPatternDel(pattern, FC_SLANT);
    FcPatternAddInteger(pattern, FC_SLANT, FC_SLANT_ROMAN);
    if (xloadfont(&dc.bfont, pattern))
        die("can't open font %s\n", fontstr);

    FcPatternDestroy(pattern);
}

void xunloadfont(Font *f) {
    XftFontClose(xw.dpy, f->match);
    FcPatternDestroy(f->pattern);
    if (f->set)
        FcFontSetDestroy(f->set);
}

void xunloadfonts(void) {
    /* Clear Harfbuzz font cache. */
    hbunloadfonts();

    /* Free the loaded fonts in the font cache.  */
    while (frclen > 0)
        XftFontClose(xw.dpy, frc[--frclen].font);

    xunloadfont(&dc.font);
    xunloadfont(&dc.bfont);
    xunloadfont(&dc.ifont);
    xunloadfont(&dc.ibfont);
}

int ximopen(Display *dpy) {
    XIMCallback imdestroy = {.client_data = NULL, .callback = ximdestroy};
    XICCallback icdestroy = {.client_data = NULL, .callback = xicdestroy};

    xw.ime.xim = XOpenIM(xw.dpy, NULL, NULL, NULL);
    if (xw.ime.xim == NULL)
        return 0;

    if (XSetIMValues(xw.ime.xim, XNDestroyCallback, &imdestroy, NULL))
        fprintf(
            stderr,
            "XSetIMValues: "
            "Could not set XNDestroyCallback.\n");

    xw.ime.spotlist = XVaCreateNestedList(0, XNSpotLocation, &xw.ime.spot, NULL);

    if (xw.ime.xic == NULL) {
        xw.ime.xic =
            XCreateIC(xw.ime.xim, XNInputStyle, XIMPreeditNothing | XIMStatusNothing, XNClientWindow, xw.win, XNDestroyCallback, &icdestroy, NULL);
    }
    if (xw.ime.xic == NULL)
        fprintf(stderr, "XCreateIC: Could not create input context.\n");

    return 1;
}

void ximinstantiate(Display *dpy, XPointer client, XPointer call) {
    if (ximopen(dpy))
        XUnregisterIMInstantiateCallback(xw.dpy, NULL, NULL, NULL, ximinstantiate, NULL);
}

void ximdestroy(XIM xim, XPointer client, XPointer call) {
    xw.ime.xim = NULL;
    XRegisterIMInstantiateCallback(xw.dpy, NULL, NULL, NULL, ximinstantiate, NULL);
    XFree(xw.ime.spotlist);
}

int xicdestroy(XIC xim, XPointer client, XPointer call) {
    xw.ime.xic = NULL;
    return 1;
}

void xinit(int cols, int rows) {
    XGCValues gcvalues;
    Cursor cursor;
    Window parent;
    pid_t thispid = getpid();
    XColor xmousefg, xmousebg;
    XWindowAttributes attr;
    XVisualInfo vis;

    if (!(xw.dpy = XOpenDisplay(NULL)))
        die("can't open display\n");
    xw.scr = XDefaultScreen(xw.dpy);

    if (!(opt_embed && (parent = strtol(opt_embed, NULL, 0)))) {
        parent   = XRootWindow(xw.dpy, xw.scr);
        xw.depth = 32;
    } else {
        XGetWindowAttributes(xw.dpy, parent, &attr);
        xw.depth = attr.depth;
    }

    XMatchVisualInfo(xw.dpy, xw.scr, xw.depth, TrueColor, &vis);
    xw.vis = vis.visual;

    /* font */
    if (!FcInit())
        die("could not init fontconfig.\n");

    usedfont = (opt_font == NULL) ? font : opt_font;
    xloadfonts(usedfont, 0);

    /* colors */
    xw.cmap = XCreateColormap(xw.dpy, parent, xw.vis, None);
    xloadcols();

    /* adjust fixed window geometry */
    win.w = 2 * win.hborderpx + 2 * borderpx + cols * win.cw;
    win.h = 2 * win.vborderpx + 2 * borderpx + rows * win.ch;
    if (xw.gm & XNegative)
        xw.l += DisplayWidth(xw.dpy, xw.scr) - win.w - 2;
    if (xw.gm & YNegative)
        xw.t += DisplayHeight(xw.dpy, xw.scr) - win.h - 2;

    /* Events */
    xw.attrs.background_pixel = dc.col[defaultbg].pixel;
    xw.attrs.border_pixel     = dc.col[defaultbg].pixel;
    xw.attrs.bit_gravity      = NorthWestGravity;
    xw.attrs.event_mask       = FocusChangeMask | KeyPressMask | KeyReleaseMask | ExposureMask | VisibilityChangeMask | StructureNotifyMask |
                          ButtonMotionMask | ButtonPressMask | ButtonReleaseMask;
    xw.attrs.colormap = xw.cmap;

    xw.win = XCreateWindow(
        xw.dpy,
        parent,
        xw.l,
        xw.t,
        win.w,
        win.h,
        0,
        xw.depth,
        InputOutput,
        xw.vis,
        CWBackPixel | CWBorderPixel | CWBitGravity | CWEventMask | CWColormap,
        &xw.attrs);

    memset(&gcvalues, 0, sizeof(gcvalues));
    gcvalues.graphics_exposures = False;
    xw.buf                      = XCreatePixmap(xw.dpy, xw.win, win.w, win.h, xw.depth);
    dc.gc                       = XCreateGC(xw.dpy, xw.buf, GCGraphicsExposures, &gcvalues);
    XSetForeground(xw.dpy, dc.gc, dc.col[defaultbg].pixel);
    XFillRectangle(xw.dpy, xw.buf, dc.gc, 0, 0, win.w, win.h);

    /* font spec buffer */
    xw.specbuf = xmalloc(cols * sizeof(GlyphFontSpec));

    /* Xft rendering context */
    xw.draw = XftDrawCreate(xw.dpy, xw.buf, xw.vis, xw.cmap);

    /* input methods */
    if (!ximopen(xw.dpy)) {
        XRegisterIMInstantiateCallback(xw.dpy, NULL, NULL, NULL, ximinstantiate, NULL);
    }

    /* white cursor, black outline */
    cursor = XCreateFontCursor(xw.dpy, mouseshape);
    XDefineCursor(xw.dpy, xw.win, cursor);

    if (XParseColor(xw.dpy, xw.cmap, colorname[mousefg], &xmousefg) == 0) {
        xmousefg.red   = 0xffff;
        xmousefg.green = 0xffff;
        xmousefg.blue  = 0xffff;
    }

    if (XParseColor(xw.dpy, xw.cmap, colorname[mousebg], &xmousebg) == 0) {
        xmousebg.red   = 0x0000;
        xmousebg.green = 0x0000;
        xmousebg.blue  = 0x0000;
    }

    XRecolorCursor(xw.dpy, cursor, &xmousefg, &xmousebg);

    xw.xembed        = XInternAtom(xw.dpy, "_XEMBED", False);
    xw.wmdeletewin   = XInternAtom(xw.dpy, "WM_DELETE_WINDOW", False);
    xw.netwmname     = XInternAtom(xw.dpy, "_NET_WM_NAME", False);
    xw.netwmiconname = XInternAtom(xw.dpy, "_NET_WM_ICON_NAME", False);
    XSetWMProtocols(xw.dpy, xw.win, &xw.wmdeletewin, 1);

    xw.netwmpid = XInternAtom(xw.dpy, "_NET_WM_PID", False);
    XChangeProperty(xw.dpy, xw.win, xw.netwmpid, XA_CARDINAL, 32, PropModeReplace, (uchar *) &thispid, 1);

    win.mode = MODE_NUMLOCK;
    resettitle();
    xhints();
    XMapWindow(xw.dpy, xw.win);
    XSync(xw.dpy, False);

    clock_gettime(CLOCK_MONOTONIC, &xsel.tclick1);
    clock_gettime(CLOCK_MONOTONIC, &xsel.tclick2);
    xsel.primary   = NULL;
    xsel.clipboard = NULL;
    xsel.xtarget   = XInternAtom(xw.dpy, "UTF8_STRING", 0);
    if (xsel.xtarget == None)
        xsel.xtarget = XA_STRING;

    boxdraw_xinit(xw.dpy, xw.cmap, xw.draw, xw.vis);
}

int xmakeglyphfontspecs(XftGlyphFontSpec *specs, const Glyph *glyphs, int len, int x, int y) {
    float winx = win.hborderpx + x * win.cw, winy = win.vborderpx + y * win.ch, xp, yp;
    ushort mode, prevmode                         = USHRT_MAX;
    Font *font      = &dc.font;
    int frcflags    = FRC_NORMAL;
    float runewidth = win.cw;
    Rune rune;
    FT_UInt glyphidx;
    FcResult fcres;
    FcPattern *fcpattern, *fontpattern;
    FcFontSet *fcsets[] = {NULL};
    FcCharSet *fccharset;
    int i, f, numspecs = 0;

    for (i = 0, xp = winx, yp = winy + font->ascent; i < len; ++i) {
        /* Fetch rune and mode for current glyph. */
        rune = glyphs[i].u;
        mode = glyphs[i].mode;

        /* Skip dummy wide-character spacing. */
        if (mode & ATTR_WDUMMY)
            continue;

        /* Determine font for glyph if different from previous glyph. */
        if (prevmode != mode) {
            prevmode  = mode;
            font      = &dc.font;
            frcflags  = FRC_NORMAL;
            runewidth = win.cw * ((mode & ATTR_WIDE) ? 2.0f : 1.0f);
            if ((mode & ATTR_ITALIC) && (mode & ATTR_BOLD)) {
                font     = &dc.ibfont;
                frcflags = FRC_ITALICBOLD;
            } else if (mode & ATTR_ITALIC) {
                font     = &dc.ifont;
                frcflags = FRC_ITALIC;
            } else if (mode & ATTR_BOLD) {
                font     = &dc.bfont;
                frcflags = FRC_BOLD;
            }
            yp = winy + font->ascent;
        }

        if (mode & ATTR_BOXDRAW) {
            /* minor shoehorning: boxdraw uses only this ushort */
            glyphidx = boxdrawindex(&glyphs[i]);
        } else {
            /* Lookup character index with default font. */
            glyphidx = XftCharIndex(xw.dpy, font->match, rune);
        }
        if (glyphidx) {
            specs[numspecs].font  = font->match;
            specs[numspecs].glyph = glyphidx;
            specs[numspecs].x     = (short) xp;
            specs[numspecs].y     = (short) yp;
            xp += runewidth;
            numspecs++;
            continue;
        }

        /* Fallback on font cache, search the font cache for match. */
        for (f = 0; f < frclen; f++) {
            glyphidx = XftCharIndex(xw.dpy, frc[f].font, rune);
            /* Everything correct. */
            if (glyphidx && frc[f].flags == frcflags)
                break;
            /* We got a default font for a not found glyph. */
            if (!glyphidx && frc[f].flags == frcflags && frc[f].unicodep == rune) {
                break;
            }
        }

        /* Nothing was found. Use fontconfig to find matching font. */
        if (f >= frclen) {
            if (!font->set)
                font->set = FcFontSort(0, font->pattern, 1, 0, &fcres);
            fcsets[0] = font->set;

            /*
             * Nothing was found in the cache. Now use
             * some dozen of Fontconfig calls to get the
             * font for one single character.
             *
             * Xft and fontconfig are design failures.
             */
            fcpattern = FcPatternDuplicate(font->pattern);
            fccharset = FcCharSetCreate();

            FcCharSetAddChar(fccharset, rune);
            FcPatternAddCharSet(fcpattern, FC_CHARSET, fccharset);
            FcPatternAddBool(fcpattern, FC_SCALABLE, 1);

            FcConfigSubstitute(0, fcpattern, FcMatchPattern);
            FcDefaultSubstitute(fcpattern);

            fontpattern = FcFontSetMatch(0, fcsets, 1, fcpattern, &fcres);

            /* Allocate memory for the new cache entry. */
            if (frclen >= frccap) {
                frccap += 16;
                frc = xrealloc(frc, frccap * sizeof(Fontcache));
            }

            frc[frclen].font = XftFontOpenPattern(xw.dpy, fontpattern);
            if (!frc[frclen].font)
                die("XftFontOpenPattern failed seeking fallback font: %s\n", strerror(errno));
            frc[frclen].flags    = frcflags;
            frc[frclen].unicodep = rune;

            glyphidx = XftCharIndex(xw.dpy, frc[frclen].font, rune);

            f = frclen;
            frclen++;

            FcPatternDestroy(fcpattern);
            FcCharSetDestroy(fccharset);
        }

        specs[numspecs].font  = frc[f].font;
        specs[numspecs].glyph = glyphidx;
        specs[numspecs].x     = (short) xp;
        specs[numspecs].y     = (short) yp;
        xp += runewidth;
        numspecs++;
    }

    /* Harfbuzz transformation for ligatures. */
    hbtransform(specs, glyphs, len, x, y);

    return numspecs;
}

void xdrawglyphfontspecs(const XftGlyphFontSpec *specs, Glyph base, int len, int x, int y, int dmode) {
    int charlen = len * ((base.mode & ATTR_WIDE) ? 2 : 1);
    int winx = win.hborderpx + x * win.cw, winy = win.vborderpx + y * win.ch, width = charlen * win.cw;
    Color *fg, *bg, *temp, revfg, revbg, truefg, truebg;
    XRenderColor colfg, colbg;
    XRectangle r;

    /* Fallback on color display for attributes not supported by the font */
    if (base.mode & ATTR_ITALIC && base.mode & ATTR_BOLD) {
        if (dc.ibfont.badslant || dc.ibfont.badweight)
            base.fg = defaultattr;
    } else if ((base.mode & ATTR_ITALIC && dc.ifont.badslant) || (base.mode & ATTR_BOLD && dc.bfont.badweight)) {
        base.fg = defaultattr;
    }

    if (IS_TRUECOL(base.fg)) {
        colfg.alpha = 0xffff;
        colfg.red   = TRUERED(base.fg);
        colfg.green = TRUEGREEN(base.fg);
        colfg.blue  = TRUEBLUE(base.fg);
        XftColorAllocValue(xw.dpy, xw.vis, xw.cmap, &colfg, &truefg);
        fg = &truefg;
    } else {
        fg = &dc.col[base.fg];
    }

    if (IS_TRUECOL(base.bg)) {
        colbg.alpha = 0xffff;
        colbg.green = TRUEGREEN(base.bg);
        colbg.red   = TRUERED(base.bg);
        colbg.blue  = TRUEBLUE(base.bg);
        XftColorAllocValue(xw.dpy, xw.vis, xw.cmap, &colbg, &truebg);
        bg = &truebg;
    } else {
        bg = &dc.col[base.bg];
    }

    /* Change basic system colors [0-7] to bright system colors [8-15] */
    if ((base.mode & ATTR_BOLD_FAINT) == ATTR_BOLD && BETWEEN(base.fg, 0, 7))
        fg = &dc.col[base.fg + 8];

    if (IS_SET(MODE_REVERSE)) {
        if (fg == &dc.col[defaultfg]) {
            fg = &dc.col[defaultbg];
        } else {
            colfg.red   = ~fg->color.red;
            colfg.green = ~fg->color.green;
            colfg.blue  = ~fg->color.blue;
            colfg.alpha = fg->color.alpha;
            XftColorAllocValue(xw.dpy, xw.vis, xw.cmap, &colfg, &revfg);
            fg = &revfg;
        }

        if (bg == &dc.col[defaultbg]) {
            bg = &dc.col[defaultfg];
        } else {
            colbg.red   = ~bg->color.red;
            colbg.green = ~bg->color.green;
            colbg.blue  = ~bg->color.blue;
            colbg.alpha = bg->color.alpha;
            XftColorAllocValue(xw.dpy, xw.vis, xw.cmap, &colbg, &revbg);
            bg = &revbg;
        }
    }

    if ((base.mode & ATTR_BOLD_FAINT) == ATTR_FAINT) {
        colfg.red   = fg->color.red / 2;
        colfg.green = fg->color.green / 2;
        colfg.blue  = fg->color.blue / 2;
        colfg.alpha = fg->color.alpha;
        XftColorAllocValue(xw.dpy, xw.vis, xw.cmap, &colfg, &revfg);
        fg = &revfg;
    }

    if (base.mode & ATTR_REVERSE) {
        temp = fg;
        fg   = bg;
        bg   = temp;
    }

    if (base.mode & ATTR_BLINK && win.mode & MODE_BLINK)
        fg = bg;

    if (base.mode & ATTR_INVISIBLE)
        fg = bg;

    if (dmode & DRAW_BG) {
        /* Intelligent cleaning up of the borders. */
        if (x == 0) {
            xclear(0, (y == 0) ? 0 : winy, borderpx, winy + win.ch + ((winy + win.ch >= borderpx + win.th) ? win.h : 0));
        }
        if (winx + width >= borderpx + win.tw) {
            xclear(winx + width, (y == 0) ? 0 : winy, win.w, ((winy + win.ch >= borderpx + win.th) ? win.h : (winy + win.ch)));
        }
        if (y == 0)
            xclear(winx, 0, winx + width, borderpx);
        if (winy + win.ch >= borderpx + win.th)
            xclear(winx, winy + win.ch, winx + width, win.h);
        /* Fill the background */
        XftDrawRect(xw.draw, bg, winx, winy, width, win.ch);
    }

    if (dmode & DRAW_FG) {
        if (base.mode & ATTR_BOXDRAW) {
            drawboxes(winx, winy, width / len, win.ch, fg, bg, specs, len);
        } else {
            /* Render the glyphs. */
            XftDrawGlyphFontSpec(xw.draw, fg, specs, len);
        }
        /* Render underline and strikethrough. */
        if (base.mode & ATTR_UNDERLINE) {
            XftDrawRect(xw.draw, fg, winx, winy + dc.font.ascent + 1, width, 1);
        }

        if (base.mode & ATTR_STRUCK) {
            XftDrawRect(xw.draw, fg, winx, winy + 2 * dc.font.ascent / 3, width, 1);
        }
    }
}

void xdrawglyph(Glyph g, int x, int y) {
    int numspecs;
    XftGlyphFontSpec spec;

    numspecs = xmakeglyphfontspecs(&spec, &g, 1, x, y);
    xdrawglyphfontspecs(&spec, g, numspecs, x, y, DRAW_BG | DRAW_FG);
}

void xdrawcursor(int cx, int cy, Glyph g, int ox, int oy, Glyph og, Line line, int len) {
    Color drawcol;

    /* remove the old cursor */
    if (selected(ox, oy))
        og.mode ^= ATTR_REVERSE;

    /* Redraw the line where cursor was previously.
     * It will restore the ligatures broken by the cursor. */
    xdrawline(line, 0, oy, len);

    if (IS_SET(MODE_HIDE))
        return;

    /*
     * Select the right color for the right mode.
     */
    g.mode &= ATTR_BOLD | ATTR_ITALIC | ATTR_UNDERLINE | ATTR_STRUCK | ATTR_WIDE | ATTR_BOXDRAW;

    if (IS_SET(MODE_REVERSE)) {
        g.mode |= ATTR_REVERSE;
        g.bg = defaultfg;
        if (selected(cx, cy)) {
            drawcol = dc.col[defaultcs];
            g.fg    = defaultrcs;
        } else {
            drawcol = dc.col[defaultrcs];
            g.fg    = defaultcs;
        }
    } else {
        if (selected(cx, cy)) {
            g.fg = defaultfg;
            g.bg = defaultrcs;
        } else {
            g.fg = defaultbg;
            g.bg = defaultcs;
        }
        drawcol = dc.col[g.bg];
    }

    /* draw the new one */
    if (IS_SET(MODE_FOCUSED)) {
        switch (win.cursor) {
            case 7:           /* st extension */
                g.u = 0x2603; /* snowman (U+2603) */
                              /* FALLTHROUGH */
            case 0:           /* Blinking Block */
            case 1:           /* Blinking Block (Default) */
            case 2:           /* Steady Block */
                xdrawglyph(g, cx, cy);
                break;
            case 3: /* Blinking Underline */
            case 4: /* Steady Underline */
                XftDrawRect(
                    xw.draw, &drawcol, win.hborderpx + cx * win.cw, win.vborderpx + (cy + 1) * win.ch - cursorthickness, win.cw, cursorthickness);
                break;
            case 5: /* Blinking bar */
            case 6: /* Steady bar */
                XftDrawRect(xw.draw, &drawcol, win.hborderpx + cx * win.cw, win.vborderpx + cy * win.ch, cursorthickness, win.ch);
                break;
        }
    } else {
        XftDrawRect(xw.draw, &drawcol, win.hborderpx + cx * win.cw, win.vborderpx + cy * win.ch, win.cw - 1, 1);
        XftDrawRect(xw.draw, &drawcol, win.hborderpx + cx * win.cw, win.vborderpx + cy * win.ch, 1, win.ch - 1);
        XftDrawRect(xw.draw, &drawcol, win.hborderpx + (cx + 1) * win.cw - 1, win.vborderpx + cy * win.ch, 1, win.ch - 1);
        XftDrawRect(xw.draw, &drawcol, win.hborderpx + cx * win.cw, win.vborderpx + (cy + 1) * win.ch - 1, win.cw, 1);
    }
}

void xsetenv(void) {
    char buf[sizeof(long) * 8 + 1];

    snprintf(buf, sizeof(buf), "%lu", xw.win);
    setenv("WINDOWID", buf, 1);
}

void xseticontitle(char *p) {
    XTextProperty prop;
    DEFAULT(p, opt_title);

    if (Xutf8TextListToTextProperty(xw.dpy, &p, 1, XUTF8StringStyle, &prop) != Success)
        return;
    XSetWMIconName(xw.dpy, xw.win, &prop);
    XSetTextProperty(xw.dpy, xw.win, &prop, xw.netwmiconname);
    XFree(prop.value);
}

void xsettitle(char *p) {
    XTextProperty prop;
    DEFAULT(p, opt_title);

    if (Xutf8TextListToTextProperty(xw.dpy, &p, 1, XUTF8StringStyle, &prop) != Success)
        return;
    XSetWMName(xw.dpy, xw.win, &prop);
    XSetTextProperty(xw.dpy, xw.win, &prop, xw.netwmname);
    XFree(prop.value);
}

int xstartdraw(void) {
    return IS_SET(MODE_VISIBLE);
}

void xdrawline(Line line, int x1, int y1, int x2) {
    int i, x, ox, numspecs, numspecs_cached;
    Glyph base, new;
    XftGlyphFontSpec *specs;

    numspecs_cached = xmakeglyphfontspecs(xw.specbuf, &line[x1], x2 - x1, x1, y1);

    /* Draw line in 2 passes: background and foreground. This way wide glyphs
       won't get truncated (#223) */
    for (int dmode = DRAW_BG; dmode <= DRAW_FG; dmode <<= 1) {
        specs    = xw.specbuf;
        numspecs = numspecs_cached;
        i = ox = 0;
        for (x = x1; x < x2 && i < numspecs; x++) {
            new = line[x];
            if (new.mode == ATTR_WDUMMY)
                continue;
            if (selected(x, y1))
                new.mode ^= ATTR_REVERSE;
            if (i > 0 && ATTRCMP(base, new)) {
                xdrawglyphfontspecs(specs, base, i, ox, y1, dmode);
                specs += i;
                numspecs -= i;
                i = 0;
            }
            if (i == 0) {
                ox   = x;
                base = new;
            }
            i++;
        }
        if (i > 0)
            xdrawglyphfontspecs(specs, base, i, ox, y1, dmode);
    }
}

void xfinishdraw(void) {
    XCopyArea(xw.dpy, xw.buf, xw.win, dc.gc, 0, 0, win.w, win.h, 0, 0);
    XSetForeground(xw.dpy, dc.gc, dc.col[IS_SET(MODE_REVERSE) ? defaultfg : defaultbg].pixel);
}

void xximspot(int x, int y) {
    if (xw.ime.xic == NULL)
        return;

    xw.ime.spot.x = borderpx + x * win.cw;
    xw.ime.spot.y = borderpx + (y + 1) * win.ch;

    XSetICValues(xw.ime.xic, XNPreeditAttributes, xw.ime.spotlist, NULL);
}

void expose(XEvent *ev) {
    redraw();
}

void visibility(XEvent *ev) {
    XVisibilityEvent *e = &ev->xvisibility;

    MODBIT(win.mode, e->state != VisibilityFullyObscured, MODE_VISIBLE);
}

void unmap(XEvent *ev) {
    win.mode &= ~MODE_VISIBLE;
}

void xsetpointermotion(int set) {
    MODBIT(xw.attrs.event_mask, set, PointerMotionMask);
    XChangeWindowAttributes(xw.dpy, xw.win, CWEventMask, &xw.attrs);
}

void xsetmode(int set, unsigned int flags) {
    int mode = win.mode;
    MODBIT(win.mode, set, flags);
    if ((win.mode & MODE_REVERSE) != (mode & MODE_REVERSE))
        redraw();
}

int xsetcursor(int cursor) {
    if (!BETWEEN(cursor, 0, 7)) /* 7: st extension */
        return 1;
    win.cursor = cursor;
    return 0;
}

void xseturgency(int add) {
    XWMHints *h = XGetWMHints(xw.dpy, xw.win);

    MODBIT(h->flags, add, XUrgencyHint);
    XSetWMHints(xw.dpy, xw.win, h);
    XFree(h);
}

void xbell(void) {
    if (!(IS_SET(MODE_FOCUSED)))
        xseturgency(1);
    if (bellvolume)
        XkbBell(xw.dpy, xw.win, bellvolume, (Atom) NULL);
}

void focus(XEvent *ev) {
    XFocusChangeEvent *e = &ev->xfocus;

    if (e->mode == NotifyGrab)
        return;

    if (ev->type == FocusIn) {
        if (xw.ime.xic)
            XSetICFocus(xw.ime.xic);
        win.mode |= MODE_FOCUSED;
        xseturgency(0);
        if (IS_SET(MODE_FOCUS))
            ttywrite("\033[I", 3, 0);
    } else {
        if (xw.ime.xic)
            XUnsetICFocus(xw.ime.xic);
        win.mode &= ~MODE_FOCUSED;
        if (IS_SET(MODE_FOCUS))
            ttywrite("\033[O", 3, 0);
    }
}

int match(uint mask, uint state) {
    return mask == XK_ANY_MOD || mask == (state & ~ignoremod);
}

char *kmap(KeySym k, uint state) {
    Key *kp;
    int i;

    /* Check for mapped keys out of X11 function keys. */
    for (i = 0; i < LEN(mappedkeys); i++) {
        if (mappedkeys[i] == k)
            break;
    }
    if (i == LEN(mappedkeys)) {
        if ((k & 0xFFFF) < 0xFD00)
            return NULL;
    }

    for (kp = key; kp < key + LEN(key); kp++) {
        if (kp->k != k)
            continue;

        if (!match(kp->mask, state))
            continue;

        if (IS_SET(MODE_APPKEYPAD) ? kp->appkey < 0 : kp->appkey > 0)
            continue;
        if (IS_SET(MODE_NUMLOCK) && kp->appkey == 2)
            continue;

        if (IS_SET(MODE_APPCURSOR) ? kp->appcursor < 0 : kp->appcursor > 0)
            continue;

        return kp->s;
    }

    return NULL;
}

void kpress(XEvent *ev) {
    XKeyEvent *e = &ev->xkey;
    KeySym ksym  = NoSymbol;
    char buf[64], *customkey;
    int len;
    Rune c;
    Status status;
    Shortcut *bp;

    if (IS_SET(MODE_KBDLOCK))
        return;

    if (xw.ime.xic) {
        len = XmbLookupString(xw.ime.xic, e, buf, sizeof buf, &ksym, &status);
        if (status == XBufferOverflow)
            return;
    } else {
        len = XLookupString(e, buf, sizeof buf, &ksym, NULL);
    }
    /* 1. shortcuts */
    for (bp = shortcuts; bp < shortcuts + LEN(shortcuts); bp++) {
        if (ksym == bp->keysym && match(bp->mod, e->state)) {
            bp->func(&(bp->arg));
            return;
        }
    }

    /* 2. custom keys from config.h */
    if ((customkey = kmap(ksym, e->state))) {
        ttywrite(customkey, strlen(customkey), 1);
        return;
    }

    /* 3. composed string from input method */
    if (len == 0)
        return;
    if (len == 1 && e->state & Mod1Mask) {
        if (IS_SET(MODE_8BIT)) {
            if (*buf < 0177) {
                c   = *buf | 0x80;
                len = utf8encode(c, buf);
            }
        } else {
            buf[1] = buf[0];
            buf[0] = '\033';
            len    = 2;
        }
    }
    ttywrite(buf, len, 1);
}

void cmessage(XEvent *e) {
    /*
     * See xembed specs
     *  http://standards.freedesktop.org/xembed-spec/xembed-spec-latest.html
     */
    if (e->xclient.message_type == xw.xembed && e->xclient.format == 32) {
        if (e->xclient.data.l[1] == XEMBED_FOCUS_IN) {
            win.mode |= MODE_FOCUSED;
            xseturgency(0);
        } else if (e->xclient.data.l[1] == XEMBED_FOCUS_OUT) {
            win.mode &= ~MODE_FOCUSED;
        }
    } else if (e->xclient.data.l[0] == xw.wmdeletewin) {
        ttyhangup();
        exit(0);
    }
}

void resize(XEvent *e) {
    if (e->xconfigure.width == win.w && e->xconfigure.height == win.h)
        return;

    cresize(e->xconfigure.width, e->xconfigure.height);
}

void run(void) {
    XEvent ev;
    int w = win.w, h = win.h;
    fd_set rfd;
    int xfd = XConnectionNumber(xw.dpy), ttyfd, xev, drawing;
    struct timespec seltv, *tv, now, lastblink, trigger;
    double timeout;

    /* Waiting for window mapping */
    do {
        XNextEvent(xw.dpy, &ev);
        /*
         * This XFilterEvent call is required because of XOpenIM. It
         * does filter out the key event and some client message for
         * the input method too.
         */
        if (XFilterEvent(&ev, None))
            continue;
        if (ev.type == ConfigureNotify) {
            w = ev.xconfigure.width;
            h = ev.xconfigure.height;
        }
    } while (ev.type != MapNotify);

    ttyfd = ttynew(opt_line, shell, opt_io, opt_cmd);
    cresize(w, h);

    for (timeout = -1, drawing = 0, lastblink = (struct timespec) {0};;) {
        FD_ZERO(&rfd);
        FD_SET(ttyfd, &rfd);
        FD_SET(xfd, &rfd);

        if (XPending(xw.dpy))
            timeout = 0; /* existing events might not set xfd */

        seltv.tv_sec  = timeout / 1E3;
        seltv.tv_nsec = 1E6 * (timeout - 1E3 * seltv.tv_sec);
        tv            = timeout >= 0 ? &seltv : NULL;

        if (pselect(MAX(xfd, ttyfd) + 1, &rfd, NULL, NULL, tv, NULL) < 0) {
            if (errno == EINTR)
                continue;
            die("select failed: %s\n", strerror(errno));
        }
        clock_gettime(CLOCK_MONOTONIC, &now);

        if (FD_ISSET(ttyfd, &rfd))
            ttyread();

        xev = 0;
        while (XPending(xw.dpy)) {
            xev = 1;
            XNextEvent(xw.dpy, &ev);
            if (XFilterEvent(&ev, None))
                continue;
            if (handler[ev.type])
                (handler[ev.type])(&ev);
        }

        /*
         * To reduce flicker and tearing, when new content or event
         * triggers drawing, we first wait a bit to ensure we got
         * everything, and if nothing new arrives - we draw.
         * We start with trying to wait minlatency ms. If more content
         * arrives sooner, we retry with shorter and shorter periods,
         * and eventually draw even without idle after maxlatency ms.
         * Typically this results in low latency while interacting,
         * maximum latency intervals during `cat huge.txt`, and perfect
         * sync with periodic updates from animations/key-repeats/etc.
         */
        if (FD_ISSET(ttyfd, &rfd) || xev) {
            if (!drawing) {
                trigger = now;
                drawing = 1;
            }
            timeout = (maxlatency - TIMEDIFF(now, trigger)) / maxlatency * minlatency;
            if (timeout > 0)
                continue; /* we have time, try to find idle */
        }

        /* idle detected or maxlatency exhausted -> draw */
        timeout = -1;
        if (blinktimeout && tattrset(ATTR_BLINK)) {
            timeout = blinktimeout - TIMEDIFF(now, lastblink);
            if (timeout <= 0) {
                if (-timeout > blinktimeout) /* start visible */
                    win.mode |= MODE_BLINK;
                win.mode ^= MODE_BLINK;
                tsetdirtattr(ATTR_BLINK);
                lastblink = now;
                timeout   = blinktimeout;
            }
        }

        draw();
        XFlush(xw.dpy);
        drawing = 0;
    }
}

void usage(void) {
    die("usage: %s [-aiv] [-c class] [-f font] [-g geometry]"
        " [-n name] [-o file]\n"
        "          [-T title] [-t title] [-w windowid]"
        " [[-e] command [args ...]]\n"
        "       %s [-aiv] [-c class] [-f font] [-g geometry]"
        " [-n name] [-o file]\n"
        "          [-T title] [-t title] [-w windowid] -l line"
        " [stty_args ...]\n",
        argv0,
        argv0);
}

int main(int argc, char *argv[]) {
    xw.l = xw.t = 0;
    xw.isfixed  = False;
    xsetcursor(cursorshape);

    ARGBEGIN {
        case 'a':
            allowaltscreen = 0;
            break;
        case 'A':
            opt_alpha = EARGF(usage());
            break;
        case 'c':
            opt_class = EARGF(usage());
            break;
        case 'e':
            if (argc > 0)
                --argc, ++argv;
            goto run;
        case 'f':
            opt_font = EARGF(usage());
            break;
        case 'g':
            xw.gm = XParseGeometry(EARGF(usage()), &xw.l, &xw.t, &cols, &rows);
            break;
        case 'i':
            xw.isfixed = 1;
            break;
        case 'o':
            opt_io = EARGF(usage());
            break;
        case 'l':
            opt_line = EARGF(usage());
            break;
        case 'n':
            opt_name = EARGF(usage());
            break;
        case 't':
        case 'T':
            opt_title = EARGF(usage());
            break;
        case 'w':
            opt_embed = EARGF(usage());
            break;
        case 'v':
            die("%s " VERSION "\n", argv0);
            break;
        default:
            usage();
    }
    ARGEND;

run:
    if (argc > 0) /* eat all remaining arguments */
        opt_cmd = argv;

    if (!opt_title)
        opt_title = (opt_line || !opt_cmd) ? "st" : opt_cmd[0];

    setlocale(LC_CTYPE, "");
    XSetLocaleModifiers("");
    cols = MAX(cols, 1);
    rows = MAX(rows, 1);
    tnew(cols, rows);
    xinit(cols, rows);
    xsetenv();
    selinit();
    run();

    return 0;
}
