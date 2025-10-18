"""
Settings for GTimeLog
"""

from __future__ import absolute_import

import datetime
import os
from configparser import RawConfigParser

from .timelog import parse_time, parse_timedelta
from .tzoffset import TZOffset


class Settings(object):
    """Configurable settings for GTimeLog."""

    # Insane defaults
    email = 'activity-list@example.com'
    name = 'Anonymous'

    editor = 'xdg-open'
    mailer = 'x-terminal-emulator -e "mutt -H %s"'
    spreadsheet = 'xdg-open %s'

    enable_gtk_completion = True  # False enables gvim-style completion

    show_time_label = True

    hours = 8
    virtual_midnight = datetime.time(2, 0, tzinfo=TZOffset())

    task_list_url = ''
    task_list_expiry = '24 hours'

    show_office_hours = True

    report_to_url = ""

    remind_idle = '10 minutes'
    server_cert = ''
    auth_header = ''  # optional Authorization header for back-end calls (e.g: 'Bearer token')

    # Should we create '-automatic arrival-' marks in the log?
    autoarrival = True

    def _config(self):
        config = RawConfigParser()
        config.add_section('gtimelog')
        config.set('gtimelog', 'list-email', self.email)
        config.set('gtimelog', 'name', self.name)
        config.set('gtimelog', 'editor', self.editor)
        config.set('gtimelog', 'mailer', self.mailer)
        config.set('gtimelog', 'spreadsheet', self.spreadsheet)
        config.set('gtimelog', 'gtk-completion',
                   str(self.enable_gtk_completion))
        config.set('gtimelog', 'show-time-label',
                   str(self.show_time_label))
        config.set('gtimelog', 'hours', str(self.hours))
        config.set('gtimelog', 'virtual_midnight',
                   self.virtual_midnight.strftime('%H:%M'))
        config.set('gtimelog', 'task_list_url', self.task_list_url)
        config.set('gtimelog', 'task_list_expiry', self.task_list_expiry)
        config.set('gtimelog', 'show_office_hours',
                   str(self.show_office_hours))
        config.set('gtimelog', 'report_to_url', self.report_to_url)
        config.set('gtimelog', 'remind_idle', self.remind_idle)
        config.set('gtimelog', 'server_cert', self.server_cert)
        config.set('gtimelog', 'autoarrival', str(self.autoarrival))
        config.set('gtimelog', 'auth_header', self.auth_header)

        return config

    def load(self, filename):
        config = self._config()
        config.read([filename])
        self.email = config.get('gtimelog', 'list-email')
        self.name = config.get('gtimelog', 'name')
        self.editor = config.get('gtimelog', 'editor')
        self.mailer = config.get('gtimelog', 'mailer')
        self.spreadsheet = config.get('gtimelog', 'spreadsheet')
        self.enable_gtk_completion = config.getboolean('gtimelog',
                                                       'gtk-completion')
        self.show_time_label = config.getboolean('gtimelog',
                                                 'show-time-label')
        self.hours = config.getfloat('gtimelog', 'hours')
        self.virtual_midnight = parse_time(config.get('gtimelog',
                                                      'virtual_midnight'))
        self.task_list_url = config.get('gtimelog', 'task_list_url')
        self.task_list_expiry = parse_timedelta(config.get('gtimelog', 'task_list_expiry'))
        self.show_office_hours = config.getboolean('gtimelog',
                                                   'show_office_hours')
        self.report_to_url = config.get('gtimelog', 'report_to_url')
        self.remind_idle = parse_timedelta(config.get('gtimelog', 'remind_idle'))

        self.server_cert = os.path.expanduser(config.get('gtimelog', 'server_cert'))
        self.autoarrival = config.getboolean('gtimelog', 'autoarrival')
        self.auth_header = config.get('gtimelog', 'auth_header')
        # Anything shorter than 2 minutes will tick every minute
        # if self.remind_idle > datetime.timedelta (0, 120):
        #    self.remind_idle = datetime.timedelta (0, 120)

    def save(self, filename):
        config = self._config()
        with open(filename, 'w') as f:
            config.write(f)
