"""
Resource locations for running out of source checkouts and pip installs
"""

import os
import sys  # noqa: F401  # TODO: drop when synced from upstream


here = os.path.dirname(__file__)

ui_dir = here

UI_FILE = os.path.join(ui_dir, 'gtimelog.ui')
ICON_FILE = os.path.join(ui_dir, 'gtimelog.png')

LOCALE_DIR = os.path.join(here, 'locale')
