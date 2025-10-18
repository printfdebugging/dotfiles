#!/usr/bin/env python

"""A readline interface for gtimelog."""

from __future__ import print_function

import os
import signal
import sys
from datetime import datetime, timedelta
from urllib.parse import urlencode

from .collabora import RemoteTaskList, soup_session
from .main import GLib, Soup, configdir
from .settings import Settings
from .timelog import TaskList, TimeLog, format_duration_short
from .tzoffset import TZOffset


class MainWindow(object):
    """Simple readline interface for gtimelog."""

    def __init__(self, timelog, tasks, settings):
        self.timelog = timelog
        self.tasks = tasks
        self.settings = settings

        self.display_time_window(timelog.window)
        print()
        self.setup_readline()

    def setup_readline(self):
        """Setup readline for our completer."""
        import readline
        readline.parse_and_bind('tab: complete')
        readline.set_completer_delims('')
        readline.set_completer(self.completer)

    def completer(self, text, state):
        """Returns the state-th result for text, or None."""
        items = self.tasks.items
        results = [x + ': ' for x in items if x.startswith(text)] + [None]
        return results[state]

    def run(self):
        """Main loop"""
        while True:
            self.tasks.check_reload()
            try:
                line = input('timelog> ')
            except EOFError:
                print()
                break
            if not line:
                continue
            self.timelog.append(line)
            self.display_last_minute()
            print()
        self.do_submit_report(self.timelog.window)

    def display_last_minute(self):
        """Display the timelog messages of the past minute."""
        now = datetime.now(TZOffset())
        time_window = self.timelog.window_for(now - timedelta(minutes=1), now)
        self.display_time_window(time_window)

    def display_time_window(self, time_window):
        """Display the timelog messages of the current day."""
        for message in time_window.all_entries():
            self.display_message(*message)

    def display_message(self, start, end, duration, message):
        """Display one timelog message."""
        if '**' in message:
            print('[%s] [32m%s[0m' % (end, message))
        elif message.startswith(tuple(self.tasks.items)):
            print('[%s] %s' % (end, message))
        else:
            print('[%s] [31;1m%s[0m' % (end, message))

    def do_submit_report(self, time_window, automatic=False):
        """Actually submit."""
        data = {}
        for start, end, duration, message in time_window.all_entries():
            day = start.strftime('%Y-%m-%d')
            data[day] = '%s %s\n' % (format_duration_short(duration), message)
        self.upload(data, automatic)

    def upload_finished(self, session, message, automatic):
        # This is equivalent to the SOUP_STATUS_IS_TRANSPORT_ERROR() macro,
        # which is not exposed via GI (being as it is a macro).
        if message.status_code > Soup.KnownStatusCode.NONE and \
           message.status_code < Soup.KnownStatusCode.CONTINUE:
            print('Error: %s' % message.reason_phrase)
            return

        txt = message.response_body.data

        if message.status_code == 400 or txt.startswith('Failed'):
            # the server didn't like our submission
            print('Failure submitting the report:', txt)
        elif message.status_code == 200:
            print('Success submitting the report.')
        elif message.status_code == 500:
            # This means an exception on the server.
            # Don't try to stuff a whole django html exception page in the error dialog.
            # It crashes gtk-window-decorator...
            print('Internal server error occurred. Contact the Chronophage maintainer.')
        else:
            print(txt)
        sys.exit(0)

    def upload(self, data, automatic):
        if self.settings.server_cert and not os.path.exists(self.settings.server_cert):
            print("Server certificate file '%s' not found" %
                  self.settings.server_cert)

        print(data)
        print(urlencode(data))
        message = Soup.Message.new('POST', self.settings.report_to_url)
        message.request_headers.set_content_type('application/x-www-form-urlencoded', None)
        message.request_body.append(urlencode(data).encode())
        message.request_body.complete()
        _ = soup_session.queue_message(message, self.upload_finished, automatic)
        loop = GLib.MainLoop()
        loop.run()


def main():
    """Entry point, copy/pasted from gtimelog.Application but without GTK+."""
    settings = Settings()
    settings_file = os.path.join(configdir, 'gtimelogrc')
    if not os.path.exists(settings_file):
        settings.save(settings_file)
    else:
        settings.load(settings_file)
        if settings.server_cert and os.path.exists(settings.server_cert):
            soup_session.set_property('ssl-ca-file', settings.server_cert)
    timelog = TimeLog(os.path.join(configdir, 'timelog.txt'),
                      settings.virtual_midnight, settings.autoarrival)
    if settings.task_list_url:
        tasks = RemoteTaskList(settings,
                               os.path.join(configdir, 'remote-tasks.txt'))
    else:
        tasks = TaskList(os.path.join(configdir, 'tasks.txt'))
    main_window = MainWindow(timelog, tasks, settings)
    # Make ^C terminate gtimelog when hanging
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main_window.run()


if __name__ == '__main__':
    main()
