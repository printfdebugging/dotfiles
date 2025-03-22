#include <X11/Xft/Xft.h>
#include <hb-ft.h>
#include <hb.h>

void hbunloadfonts();
void hbtransform(XftGlyphFontSpec *, const Glyph *, size_t, int, int);
