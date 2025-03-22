PREFIX 		= /usr/local
MANPREFIX 	= $(PREFIX)/share/man


SRCDIR = src
INCDIR = inc
OBJDIR = obj
APPEXE = st


CFLAGS = -I$(INCDIR) \
		 -I/usr/X11R6/include \
		 -I/usr/include/freetype2  \
		 -I/usr/include/libpng16  \
		 -I/usr/include/freetype2  \
		 -I/usr/include/libpng16   \
		 -I/usr/include/harfbuzz \
		 -I/usr/include/freetype2  \
		 -I/usr/include/libpng16  \
		 -I/usr/include/glib-2.0  \
		 -I/usr/lib64/glib-2.0/include  \
		 -DVERSION=\"1\"  \
		 -D_XOPEN_SOURCE=600


LDFLAGS = -L/usr/X11R6/lib \
		  -lm \
		  -lrt \
		  -lX11 \
		  -lutil \
		  -lXft \
		  -lXrender \
		  -lfontconfig \
		  -lfreetype \
		  -lfreetype \
		  -lharfbuzz

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

install: $(APPEXE)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f $(APPEXE) $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/$(APPEXE)
	sed "s/VERSION/$(VERSION)/g" < st.1 > $(DESTDIR)$(MANPREFIX)/man1/st.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/st.1
	tic -sx st.info
