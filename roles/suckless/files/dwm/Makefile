VERSION 	= 6.5
PREFIX 		= /usr/local
MANPREFIX 	= $(PREFIX)/share/man


SRCDIR = src
INCDIR = inc
OBJDIR = obj
APPEXE = dwm


CFLAGS = -std=c99 \
		 -pedantic \
		 -Wall \
		 -Wno-deprecated-declarations \
		 -Os \
		 -I$(INCDIR) \
		 -I/usr/X11R6/include \
		 -I/usr/include/freetype2 \
		 -D_DEFAULT_SOURCE \
		 -D_BSD_SOURCE \
		 -D_XOPEN_SOURCE=700L \
		 -DVERSION=\"6.5\" \
		 -DXINERAMA 


LDFLAGS = -L/usr/X11R6/lib \
		  -lX11 \
		  -lXinerama \
		  -lfontconfig \
		  -lXft \
		  -lX11-xcb \
		  -lxcb \
		  -lxcb-res


CFILES = $(shell find $(SRCDIR) -name '*.c')
HFILES = $(shell find $(INCDIR) -name '*.h')
OFILES = $(CFILES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)


all : $(APPEXE)

$(APPEXE) : $(OFILES)
	$(CC) -o $@ $(OFILES) $(LDFLAGS)

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(APPEXE) $(OBJDIR)

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwm ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwm
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
