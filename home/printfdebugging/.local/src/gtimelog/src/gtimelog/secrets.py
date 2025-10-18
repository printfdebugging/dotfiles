"""
Keyring and secrets
"""
import functools

from .utils import require_version

require_version('GLib', '2.0')
require_version('GObject', '2.0')
require_version('Gtk', '3.0')
require_version('Soup', '2.4')
from gi.repository import GLib, GObject, Gtk, Soup


class Authenticator(object):
    def __init__(self, soup_session: Soup.SessionAsync):
        self.pending = []
        self.lookup_in_progress = False
        self.username = None
        self.password = None
        soup_session.connect('authenticate', self.http_auth_cb)

    # Try to use LibSecret if available
    try:
        import gi
        gi.require_version('Secret', '1')
        from gi.repository import Secret
        # This is defined by libsecret for migration from gnome-keyring, but it
        # isn't exported by gobject-introspection, so we redefine it here.
        SECRET_SCHEMA_COMPAT_NETWORK = Secret.Schema.new(
            "org.gnome.keyring.NetworkPassword",
            Secret.SchemaFlags.NONE,
            {
                "user": Secret.SchemaAttributeType.STRING,
                "domain": Secret.SchemaAttributeType.STRING,
                "object": Secret.SchemaAttributeType.STRING,
                "protocol": Secret.SchemaAttributeType.STRING,
                "port": Secret.SchemaAttributeType.INTEGER,
                "server": Secret.SchemaAttributeType.STRING,
                "authtype": Secret.SchemaAttributeType.STRING,
            }
        )
    except ImportError:
        print("LibSecret not found. You will not be able to use the password keyring.")
        Secret = None

    def find_in_keyring(self, uri, callback):
        """
        Attempt to load a username and password from the keyring, if the
        keyring is available.
        """
        if self.Secret is None:
            callback(None, None)
            return

        username = None
        password = None

        try:
            # FIXME: would be nice to make all keyring calls async, to dodge
            # the possibility of blocking the UI. The code is all set up for it.
            # It can be done with libsecret from Python; docs have examples.
            attrs = {
                "domain": uri.get_host(),
                "server": uri.get_host(),
                "protocol": uri.get_scheme(),
            }
            service = self.Secret.Service.get_sync(0, None)
            # This doesn't give us the password; only details from the schema
            results = service.search_sync(
                self.SECRET_SCHEMA_COMPAT_NETWORK,
                attrs, 0, None)
            if results:
                username = results[0].get_attributes()['user']
                # This gives us only the password
                password = self.Secret.password_lookup_sync(
                    self.SECRET_SCHEMA_COMPAT_NETWORK, attrs, None)
        except (GLib.Error, KeyError) as e:
            # Couldn't contact daemon, or other errors
            print("Unable to contact keyring: {0}".format(e))

        callback(username, password)

    def save_to_keyring(self, uri, username, password):
        try:
            attrs = {
                "user": username,
                "domain": uri.get_host(),
                "server": uri.get_host(),
                # BUG: Passing 'None' for a string causes a segfault
                # https://bugzilla.gnome.org/show_bug.cgi?id=685394
                "object": "",
                "protocol": uri.get_scheme(),
            }
            self.Secret.password_store_sync(
                self.SECRET_SCHEMA_COMPAT_NETWORK,
                attrs,
                self.Secret.COLLECTION_DEFAULT,
                "Chronophage password for GTimelog", password, None)
        except GLib.Error as e:
            # Couldn't contact daemon, or other errors
            print("Unable to contact keyring: {0}".format(e))

    def ask_the_user(self, auth, uri, callback):
        """Pops up a username/password dialog for uri"""
        d = Gtk.Dialog()
        d.set_title('Authentication Required')
        d.set_resizable(False)

        grid = Gtk.Grid()
        grid.set_border_width(5)
        grid.set_row_spacing(5)
        grid.set_column_spacing(5)

        lab = Gtk.Label(
            'Authentication is required for the domain "%s".' % auth.get_realm())
        lab.set_line_wrap(True)
        grid.attach(lab, 0, 0, 2, 1)

        username_label = Gtk.Label("Username:")
        grid.attach_next_to(username_label, lab, Gtk.PositionType.BOTTOM, 1, 1)

        password_label = Gtk.Label("Password:")
        grid.attach_next_to(password_label, username_label,
                            Gtk.PositionType.BOTTOM, 1, 1)

        userentry = Gtk.Entry()
        userentry.set_hexpand(True)
        passentry = Gtk.Entry()
        passentry = Gtk.Entry()
        passentry.set_visibility(False)

        userentry.set_activates_default(True)
        passentry.set_activates_default(True)

        grid.attach_next_to(userentry, username_label,
                            Gtk.PositionType.RIGHT, 1, 1)
        grid.attach_next_to(passentry, password_label,
                            Gtk.PositionType.RIGHT, 1, 1)

        if self.Secret:
            savepasstoggle = Gtk.CheckButton("Save Password in Keyring")
            savepasstoggle.set_active(True)
            grid.attach_next_to(savepasstoggle, passentry,
                                Gtk.PositionType.BOTTOM, 1, 1)

        d.vbox.pack_start(grid, True, True, 0)
        d.add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL)
        ok_button = d.add_button(Gtk.STOCK_OK, Gtk.ResponseType.OK)
        d.set_default(ok_button)

        def update_ok_sensitivity(*args):
            ok_button.set_sensitive(
                userentry.get_text() and passentry.get_text())
        userentry.connect('notify::text', update_ok_sensitivity)
        passentry.connect('notify::text', update_ok_sensitivity)
        update_ok_sensitivity()

        def on_response(dialog, r):
            save_to_keyring = self.Secret and savepasstoggle.get_active()

            if r == Gtk.ResponseType.OK:
                username = userentry.get_text()
                password = passentry.get_text()

                if username and password and save_to_keyring:
                    self.save_to_keyring(uri, username, password)

            else:
                username = None
                password = None

            d.destroy()
            callback(username, password)

        d.connect('response', on_response)
        d.show_all()

    def find_password(self, auth, uri, retrying, callback):
        def keyring_callback(username, password):
            # If not found, ask the user for it
            if username is None or retrying:
                GObject.idle_add(
                    lambda: self.ask_the_user(auth, uri, callback))
            else:
                callback(username, password)

        self.find_in_keyring(uri, keyring_callback)

    def http_auth_cb(self, session, message, auth, retrying, *args):
        session.pause_message(message)
        self.pending.insert(0, (session, message, auth, retrying))
        self.maybe_pop_queue()

    def maybe_pop_queue(self):
        # I don't think we need any locking, because GIL.
        if self.lookup_in_progress:
            return

        try:
            (session, message, auth, retrying) = self.pending.pop()
        except IndexError:
            pass
        else:
            self.lookup_in_progress = True
            uri = message.get_uri()
            self.find_password(
                auth,
                uri,
                retrying,
                callback=functools.partial(
                    self.http_auth_finish, session, message, auth)
            )

    def http_auth_finish(self, session, message, auth, username, password):
        if username and password:
            auth.authenticate(username, password)

        session.unpause_message(message)
        self.lookup_in_progress = False
        self.maybe_pop_queue()
