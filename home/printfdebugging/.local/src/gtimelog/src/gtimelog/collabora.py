"""A temporary holding zone for troublesome things."""
from __future__ import absolute_import

import datetime
import os

from .utils import require_version

require_version('Soup', '2.4')
from gi.repository import Soup

from .secrets import Authenticator
from .timelog import TaskList
from .tzoffset import TZOffset


soup_session = Soup.SessionAsync()
authenticator = Authenticator(soup_session)


class RemoteTaskList(TaskList):
    """Task list stored on a remote server.

    Keeps a cached copy of the list in a local file, so you can use it offline.
    """

    def __init__(self, settings, cache_filename):
        self.url = settings.task_list_url
        TaskList.__init__(self, cache_filename)
        self.settings = settings

        # Even better would be to use the Expires: header on the list itself I suppose...
        self.max_age = settings.task_list_expiry

        mtime = self.get_mtime()
        if mtime:
            self.last_time = datetime.datetime.fromtimestamp(mtime, TZOffset())
        else:
            self.last_time = datetime.datetime.now(
                TZOffset()) - self.max_age * 2

    def check_reload(self):
        """Check whether the task list needs to be reloaded.

        Download the task list if this is the first time, and a cached copy is
        not found.

        Returns True if the file was reloaded.
        """
        if datetime.datetime.now(TZOffset()) - self.last_time > self.max_age:
            self.last_time = datetime.datetime.now(TZOffset())
            # Always redownload if past the expiry date.
            self.download()
            return True
        return TaskList.check_reload(self)

    def download_finished_cb(self, session, message, *args):
        if message.status_code == 200:
            try:
                out = open(self.filename, 'w')
                out.write(message.response_body.data)
            except IOError as e:
                print(e)
                if self.error_callback:
                    self.error_callback()
            finally:
                out.close()
                self.load_file()
        else:
            if self.error_callback:
                self.error_callback()

    def download(self):
        """Download the task list from the server."""
        if self.loading_callback:
            self.loading_callback()

        if self.settings.server_cert and not os.path.exists(self.settings.server_cert):
            print("Server certificate file not found")

        message = Soup.Message.new('GET', self.url)

        if self.settings.auth_header:
            message.request_headers.append('Authorization', self.settings.auth_header)

        soup_session.queue_message(message, self.download_finished_cb, None)

    def load_file(self):
        """Load the file in the UI"""
        self.load()
        if self.loaded_callback:
            self.loaded_callback()

    def reload(self):
        """Reload the task list."""
        self.download()
