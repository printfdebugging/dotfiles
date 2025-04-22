PREFIX    = /usr/local
MANPREFIX = $(PREFIX)/share/man

SRCDIR    = src
INCDIR 	  = inc
OBJDIR    = obj
SCRIPTDIR = scripts
MANDIR    = man
APPEXE    = dmenu

CFLAGS = -std=c99  \
		 -pedantic  \
		 -Wall  \
		 -Os  \
		 -I$(INCDIR) \
		 -I/usr/X11R6/include  \
		 -I/usr/include/freetype2  \
		 -D_DEFAULT_SOURCE  \
		 -D_BSD_SOURCE  \
		 -D_XOPEN_SOURCE=700  \
		 -D_POSIX_C_SOURCE=200809L  \
		 -DVERSION=\"5.3\"  \
		 -DXINERAMA \

LDFLAGS = -L/usr/X11R6/lib  \
		  -lX11  \
		  -lXinerama  \
		  -lfontconfig  \
		  -lXft \
		  -lXrender \

CFILES = $(shell find $(SRCDIR) -name '*.c')
HFILES = $(shell find $(INCDIR) -name '*.h')
OFILES = $(CFILES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

all: $(APPEXE)

$(APPEXE) : $(OFILES)
	$(CC) -o $@ $(OFILES) $(LDFLAGS)
	$(CC) -o stest scripts/stest.c -Iinc

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(APPEXE) $(OBJDIR)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f stest dmenu $(SCRIPTDIR)/dmenu_path $(SCRIPTDIR)/dmenu_run $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu
	chmod 755 $(DESTDIR)$(PREFIX)/bin/stest
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu_path
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu_run
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/5.3/g" < $(MANDIR)/dmenu.1 > $(DESTDIR)$(MANPREFIX)/man1/dmenu.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/dmenu.1
