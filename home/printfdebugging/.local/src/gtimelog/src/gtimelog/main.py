#!/usr/bin/env python3
"""A Gtk+ application for keeping track of time."""
import sys
import time


DEBUG = "--debug" in sys.argv


if DEBUG:

    def mark_time(what=None, _prev=[0, 0]):
        t = time.time()
        if what:
            print("{:.3f} ({:+.3f}) {}".format(t - _prev[1], t - _prev[0], what))
        else:
            print()
            _prev[1] = t
        _prev[0] = t

else:

    def mark_time(what=None):
        pass


mark_time()
mark_time("in script")

import calendar
import csv
import datetime
import gettext
import locale
import logging
import os
import re
import signal
import sys
from urllib.parse import urlencode
from gettext import gettext as _
from tempfile import NamedTemporaryFile
import configparser as ConfigParser

import pickle

try:
    # python2..3.7, deprecated since 3.2
    from cgi import escape
except ImportError:
    # python3.8
    from html import escape

mark_time("Python imports done")


if DEBUG:
    os.environ["G_ENABLE_DIAGNOSTIC"] = "1"


# The gtimelog.paths import has important side effects and must be done before
# importing 'gi'.

from .paths import (
    ICON_FILE,
    LOCALE_DIR,
    UI_FILE,
)
from .utils import require_version


require_version("Gtk", "3.0")
require_version("Gdk", "3.0")
require_version("Soup", "2.4")
from gi.repository import Gdk, Gio, GLib, GObject, Gtk, Pango, Soup  # noqa: E402

mark_time("Gtk imports done")

from .collabora import RemoteTaskList, soup_session  # noqa: E402
from .settings import Settings  # noqa: E402
from .timelog import (
    as_hours,
    format_duration,
    format_duration_long,
    format_duration_short,
    parse_timedelta,
    TaskList,
    TimeLog,
    TimeWindow,
    uniq,
    virtual_day,
)  # noqa: E402
from .tzoffset import TZOffset  # noqa: E402

mark_time("gtimelog imports done")


log = logging.getLogger("gtimelog")

# Where we store configuration and other interesting files.
configdir = os.path.expanduser("~/repos/vault/gtimelog")

# This is for distribution packages
if not os.path.exists(UI_FILE):
    UI_FILE = "/usr/share/gtimelog/gtimelog.ui"
if not os.path.exists(ICON_FILE):
    ICON_FILE = "/usr/share/pixmaps/gtimelog.png"


class TrayIcon(object):
    """Tray icon for gtimelog."""

    def __init__(self, gtimelog_window):
        self.gtimelog_window = gtimelog_window
        self.timelog = gtimelog_window.timelog

        self.trayicon = Gtk.StatusIcon.new_from_file(ICON_FILE)

        # self.trayicon.add(self.eventbox)
        self.last_tick = False
        self.tick(force_update=True)

        tray_icon_popup_menu = gtimelog_window.tray_icon_popup_menu
        self.trayicon.connect_object(
            "button-press-event", self.on_press, tray_icon_popup_menu
        )
        self.trayicon.connect("button-release-event", self.on_release)
        GObject.timeout_add(1000, self.tick)

    def on_press(self, widget, event):
        """A mouse button was pressed on the tray icon label."""
        if event.button != 3:
            return
        main_window = self.gtimelog_window.main_window
        if main_window.get_property("visible"):
            self.gtimelog_window.tray_show.hide()
            self.gtimelog_window.tray_hide.show()
        else:
            self.gtimelog_window.tray_show.show()
            self.gtimelog_window.tray_hide.hide()
        widget.popup(None, None, None, None, event.button, event.time)

    def on_release(self, widget, event):
        """A mouse button was released on the tray icon label."""
        if event.button != 1:
            return
        main_window = self.gtimelog_window.main_window
        if main_window.get_property("visible"):
            main_window.hide()
        else:
            main_window.present()

    def entry_added(self, entry):
        """An entry has been added."""
        self.tick(force_update=True)

    def tick(self, force_update=False):
        """Tick every second."""
        now = datetime.datetime.now(TZOffset()).replace(second=0, microsecond=0)
        if now != self.last_tick or force_update:  # Do not eat CPU too much
            self.last_tick = now

        # FIXME - this should be wired up async
        self.trayicon.set_tooltip_text(self.tip())
        return True

    def tip(self):
        """Compute tooltip text."""
        current_task = self.gtimelog_window.task_entry.get_text()
        if not current_task:
            current_task = "nothing"
        tip = "GTimeLog: working on %s" % current_task
        total_work, total_slacking = self.timelog.window.totals()
        tip += "\nWork done today: %s" % format_duration(total_work)
        time_left = self.gtimelog_window.time_left_at_work(total_work)
        if time_left is not None:
            if time_left < datetime.timedelta(0):
                time_left = datetime.timedelta(0)
            tip += "\nTime left at work: %s" % format_duration(time_left)
        return tip


TODAY = 0
WEEK = 1
MONTH = 2
LAST_WEEK = 3
LAST_MONTH = 4


class MainWindow(object):
    """Main application window."""

    # Time window to display in default view
    display_window = TODAY

    # Initial view mode
    chronological = True
    show_tasks = True
    show_unavailable_tasks = False

    # URL to use for Help -> Online Documentation
    help_url = "https://gtimelog.org"

    def __init__(self, timelog, settings, tasks):
        """Create the main window."""
        self.timelog = timelog
        self.settings = settings
        self.tasks = tasks
        self.tray_icon = None
        self.last_tick = None
        self.footer_mark = None

        # Allow insert of backdated log entries
        self.welcome_back_notification = None
        self.inserting_old_time = False

        # I do not understand this at all.
        self.time_before_idle = datetime.datetime.now(TZOffset())

        # whether or not row toggle callbacks are heeded
        self._block_row_toggles = 0

        # Try to prevent timer routines mucking with the buffer while we're
        # mucking with the buffer.  Not sure if it is necessary.
        self.lock = False
        # FIXME: this should be replaced with a GLib signal...
        self.entry_watchers = [self.add_history]
        self._init_ui()
        self._init_dbus()
        self.tick(True)
        GObject.timeout_add(1000, self.tick)

    COL_TASK_NAME = 0
    COL_TASK_PATH = 1
    COL_TASK_UNAVAILABLE = 2

    def _init_ui(self):
        """Initialize the user interface."""
        builder = Gtk.Builder()
        builder.add_from_file(UI_FILE)

        # Set initial state of menu items *before* we hook up signals
        chronological_menu_item = builder.get_object("chronological")
        chronological_menu_item.set_active(self.chronological)
        show_task_pane_item = builder.get_object("show_task_pane")
        show_task_pane_item.set_active(self.show_tasks)

        self.show_unavailable_tasks_item = builder.get_object("show_unavailable_tasks")
        self.show_unavailable_tasks_item.set_active(self.show_unavailable_tasks)
        self.show_unavailable_tasks_item.set_sensitive(self.show_tasks)

        # Now hook up signals
        builder.connect_signals(self)

        # Store references to UI elements we're going to need later
        self.tray_icon_popup_menu = builder.get_object("tray_icon_popup_menu")
        self.tray_show = builder.get_object("tray_show")
        self.tray_hide = builder.get_object("tray_hide")
        self.about_dialog = builder.get_object("about_dialog")
        self.about_dialog_ok_btn = builder.get_object("ok_button")
        self.about_dialog_ok_btn.connect("clicked", self.close_about_dialog)
        self.calendar_dialog = builder.get_object("calendar_dialog")
        self.calendar = builder.get_object("calendar")
        self.calendar.connect(
            "day_selected_double_click", self.on_calendar_day_selected_double_click
        )
        self.submit_window = SubmitWindow(builder, self.settings, application=self)
        self.main_window = builder.get_object("main_window")
        self.main_window.connect("delete_event", self.delete_event)
        self.main_window.set_icon_from_file(ICON_FILE)
        self.about_dialog.set_transient_for(self.main_window)
        self.about_dialog.set_modal(True)
        self.log_view = builder.get_object("log_view")
        self.infobars = builder.get_object("infobars")
        self.set_up_log_view_columns()

        self.task_pane = builder.get_object("task_list_pane")
        if not self.show_tasks:
            self.task_pane.hide()
        self.task_pane_info_label = builder.get_object("task_pane_info_label")
        self.task_pane_spinner = builder.get_object("task_pane_spinner")
        self.tasks.loading_callback = self.task_list_loading
        self.tasks.loaded_callback = self.task_list_loaded
        self.tasks.error_callback = self.task_list_error
        self.task_list = builder.get_object("task_list")
        self.task_store = Gtk.TreeStore(str, str, bool)
        task_filter = builder.get_object("task_filter")

        filter = self.task_store.filter_new()
        self.refilter_timeout = 0

        def _refilter():
            filter.refilter()
            self.update_toggle_state()
            self.refilter_timeout = 0
            return False

        def _task_filter_changed(task_filter):
            txt = task_filter.get_text()

            task_filter.set_icon_sensitive(
                Gtk.EntryIconPosition.SECONDARY, len(txt) > 0
            )

            if self.refilter_timeout != 0:
                GObject.source_remove(self.refilter_timeout)
            self.refilter_timeout = GObject.timeout_add(200, _refilter)

        def _task_filter_clear(task_filter, icon_pos, event):
            task_filter.set_text("")

        def _task_filter_filter(model, iter, user_data):
            # If the user hasn't ticked "Show unavailable tasks" and the task
            # is unavailable, never show it, even when searching.
            if not self.show_unavailable_tasks:
                (unavailable,) = model.get(iter, MainWindow.COL_TASK_UNAVAILABLE)
                if unavailable:
                    return False

            txt = task_filter.get_text()

            if len(txt) == 0:
                return True

            model.iter_depth(iter)

            # Currently the first (0th) column of the data is the respective
            # section, as separated by :, while the second (1th) column has
            # the complete path, including the secion - foo:bar:section
            #
            # Seemingly the current format confuses the treeview model, since
            # it will traverse into the children, _even_ when the parent
            # returns false. Additionally, even as the child returns true, its
            # parents are checked and the field is displayed _only_ iff the
            # child (and later on parent) return true.
            #
            # All this is pretty weird, but using the second (1st) column gets
            # us where we want - aka show the full tree given any section is
            # matched.
            if not txt.lower() in model.get_value(iter, 1).lower():
                child = model.iter_children(iter)

                while child is not None:
                    if _task_filter_filter(model, child, None):
                        return True
                    child = model.iter_next(child)
                return False

            return True

        task_filter.connect("changed", _task_filter_changed)
        task_filter.connect("icon-release", _task_filter_clear)

        filter.set_visible_func(_task_filter_filter, None)
        self.task_list.set_model(filter)

        self.task_list.connect("row-expanded", self.on_row_expander_changed, True)
        self.task_list.connect("row-collapsed", self.on_row_expander_changed, False)

        renderer = Gtk.CellRendererText()
        column = Gtk.TreeViewColumn("Task", renderer)

        # We grey out unavailable subtrees.
        def task_column_data_func(column, cell, model, iter, user_data):
            text, grey = model.get(
                iter, MainWindow.COL_TASK_NAME, MainWindow.COL_TASK_UNAVAILABLE
            )

            renderer.set_property("text", text)

            if grey:
                renderer.set_property("foreground", "#aaaaaa")
                renderer.set_property("foreground-set", True)
            else:
                renderer.set_property("foreground", "#000000")
                renderer.set_property("foreground-set", False)

        column.set_cell_data_func(renderer, task_column_data_func)

        self.task_list.append_column(column)

        self.task_list.connect("row_activated", self.task_list_row_activated)
        self.task_list_popup_menu = builder.get_object("task_list_popup_menu")
        self.task_list.connect_object(
            "button_press_event", self.task_list_button_press, self.task_list_popup_menu
        )
        self.time_label = builder.get_object("time_label")
        self.task_entry = builder.get_object("task_entry")
        self.task_entry.connect("changed", self.task_entry_changed)
        self.task_entry.connect("key_press_event", self.task_entry_key_press)
        self.add_button = builder.get_object("add_button")
        self.add_button.connect("clicked", self.add_entry)
        buffer = self.log_view.get_buffer()
        self.log_buffer = buffer

        # Tango dark blue
        buffer.create_tag("today", foreground="#204a87")
        # Tango dark orange
        buffer.create_tag("duration", foreground="#ce5c00")
        # Tango dark green
        buffer.create_tag("time", foreground="#4e9a06")
        buffer.create_tag("slacking", foreground="gray")
        # Tango dark red
        buffer.create_tag("invalid", foreground="#a40000")

        # Reminders infrastructure
        self.weekly_report_reminder_set = False
        self.monthly_report_reminder_set = False
        self.reminder_infobar = None
        self.reminders = []

        self.set_up_completion()
        # This also triggers populating the main view
        self.set_up_task_list()
        self.set_up_history()

        self.restore_ui_state(os.path.join(configdir, "uistaterc"))

        self.auto_submit()

    def _init_dbus(self):
        try:
            dbus_bus_type = Gio.BusType.SESSION
            self.screensaver = Gio.DBusProxy.new_for_bus_sync(
                dbus_bus_type,
                0,
                None,
                "org.gnome.ScreenSaver",
                "/org/gnome/ScreenSaver",
                "org.gnome.ScreenSaver",
                None,
            )
            self.screensaving = self.screensaver.GetActive()
        except Exception:
            self.screensaving = False
            self.screensaver = None

    def quit(self):
        self.main_window.destroy()

    def restore_ui_state(self, filename):
        try:
            config = ConfigParser.RawConfigParser()
            config.read([filename])

            width = int(config.get("MainWindow", "width"))
            height = int(config.get("MainWindow", "height"))

            self.main_window.resize(width, height)

            x = int(config.get("MainWindow", "x"))
            y = int(config.get("MainWindow", "y"))

            self.main_window.move(x, y)
        except Exception as e:
            print(e.message)

    def save_ui_state(self, filename):
        try:
            uistaterc = open(filename, "w")

            config = ConfigParser.RawConfigParser()
            config.add_section("MainWindow")

            x, y = self.main_window.get_position()
            config.set("MainWindow", "x", x)
            config.set("MainWindow", "y", y)

            width, height = self.main_window.get_size()
            config.set("MainWindow", "width", width)
            config.set("MainWindow", "height", height)

            config.write(uistaterc)
            uistaterc.close()
        except Exception as e:
            print(e.message)

    def set_up_log_view_columns(self):
        """Set up tab stops in the log view."""
        pango_context = self.log_view.get_pango_context()
        em = pango_context.get_font_description().get_size()
        tabs = Pango.TabArray.new(2, False)
        tabs.set_tab(0, Pango.TabAlign.LEFT, 9 * em)
        tabs.set_tab(1, Pango.TabAlign.LEFT, 12 * em)
        self.log_view.set_tabs(tabs)

    def w(self, text, tag=None):
        """Write some text at the end of the log buffer."""
        buffer = self.log_buffer
        if tag:
            buffer.insert_with_tags_by_name(buffer.get_end_iter(), text, tag)
        else:
            buffer.insert(buffer.get_end_iter(), text)

    def populate_log(self):
        """Populate the log."""
        self.lock = True
        buffer = self.log_buffer
        buffer.set_text("")
        if self.footer_mark is not None:
            buffer.delete_mark(self.footer_mark)
            self.footer_mark = None
        today = virtual_day(
            datetime.datetime.now(TZOffset()), self.timelog.virtual_midnight
        )
        today = today.strftime("%A, %Y-%m-%d (week %V)")
        self.w(today + "\n\n", "today")

        # First, what time window we are going to show?
        if self.display_window == WEEK:
            time_window = self.weekly_window()
        elif self.display_window == MONTH:
            time_window = self.monthly_window()
        elif self.display_window == LAST_WEEK:
            day = self.timelog.day - datetime.timedelta(7)
            time_window = self.weekly_window(day=day)
        elif self.display_window == LAST_MONTH:
            day = self.timelog.day - datetime.timedelta(self.timelog.day.day)
            time_window = self.monthly_window(day)
        else:
            time_window = self.timelog.window

        # Now, let's decide how that window is going to be presented,
        # and present it.
        if self.chronological:
            for item in time_window.all_entries():
                self.write_item(item)
        else:
            work, slack = time_window.grouped_entries()
            for start, entry, duration in work + slack:
                if not duration.seconds:
                    continue
                self.write_group(entry, duration)
            where = buffer.get_end_iter()
            where.backward_cursor_position()
            buffer.place_cursor(where)

        # Finally, add general information.
        self.add_footer()
        self.scroll_to_end()
        self.lock = False

    def delete_footer(self):
        buffer = self.log_buffer
        buffer.delete(buffer.get_iter_at_mark(self.footer_mark), buffer.get_end_iter())
        buffer.delete_mark(self.footer_mark)
        self.footer_mark = None

    def get_last_acked_reminder(self, filename):
        try:
            last_acked = int(open(os.path.join(configdir, filename)).read().strip())
        except (IOError, ValueError):
            return None

        return last_acked

    @property
    def weekly_report_reminder_acked(self):
        week_number = datetime.datetime.now().isocalendar()[1]
        last_acked_week = self.get_last_acked_reminder("reminder-last-acked-week")

        if last_acked_week is None or last_acked_week != week_number:
            return False

        return True

    @property
    def monthly_report_reminder_acked(self):
        month_number = datetime.datetime.now().month
        last_acked_month = self.get_last_acked_reminder("reminder-last-acked-month")

        if last_acked_month is None or last_acked_month != month_number:
            return False

        return True

    def ack_reminder(self, filename, number):
        try:
            open(os.path.join(configdir, filename), "w").write("%d" % number)
        except IOError as e:
            print("Unable to record ack...: " + e.message)
            pass

    def ack_weekly_reminder(self, *args):
        self.weekly_report_reminder_set = False
        week_number = datetime.datetime.now().isocalendar()[1]
        self.ack_reminder("reminder-last-acked-week", week_number)

    def ack_monthly_reminder(self, *args):
        self.monthly_report_reminder_set = False
        month_number = datetime.datetime.now().month
        self.ack_reminder("reminder-last-acked-month", month_number)

    def add_footer(self):
        buffer = self.log_buffer
        self.footer_mark = buffer.create_mark("footer", buffer.get_end_iter(), True)
        total_work, total_slacking = self.timelog.window.totals()
        weekly_window = self.weekly_window()
        week_total_work, week_total_slacking = weekly_window.totals()
        work_days_this_week = weekly_window.count_days()

        self.w("\n")
        self.w("Total work done today: ")
        self.w(format_duration(total_work), "duration")
        self.w(" (")
        self.w(format_duration(week_total_work), "duration")
        self.w(" this week")
        if work_days_this_week:
            per_diem = week_total_work / work_days_this_week
            self.w(", ")
            self.w(format_duration(per_diem), "duration")
            self.w(" per day")
        self.w(")\n")
        self.w("Total slacking today: ")
        self.w(format_duration(total_slacking), "duration")
        self.w(" (")
        self.w(format_duration(week_total_slacking), "duration")
        self.w(" this week")
        if work_days_this_week:
            per_diem = week_total_slacking / work_days_this_week
            self.w(", ")
            self.w(format_duration(per_diem), "duration")
            self.w(" per day")
        self.w(")\n")
        time_left = self.time_left_at_work(total_work)
        if time_left is not None:
            time_to_leave = datetime.datetime.now(TZOffset()) + time_left
            if time_left < datetime.timedelta(0):
                time_left = datetime.timedelta(0)
            self.w("Time left at work today: ")
            self.w(format_duration(time_left), "duration")
            self.w(" (till ")
            self.w(time_to_leave.strftime("%H:%M"), "time")
            self.w(")\n")
        week_time_left = self.week_time_left_at_work(week_total_work)
        hours_per_week = datetime.timedelta(hours=self.settings.hours)
        if week_time_left is not None and week_time_left <= hours_per_week:
            time_to_leave = datetime.datetime.now(TZOffset()) + week_time_left
            if week_time_left < datetime.timedelta(0):
                week_time_left = datetime.timedelta(0)
            self.w("Time left at work for the week: ")
            self.w(format_duration(week_time_left), "duration")
            self.w(" (till ")
            self.w(time_to_leave.strftime("%H:%M"), "time")
            self.w(")\n")

        if True:
            """If you work under 35 hours some weeks and catch up in future
            weeks, you should be ashamed of yourself, but you might find this
            useful."""
            monthly_window = self.monthly_window()
            month_total_work, _ = monthly_window.totals()

            (d, h) = divmod(as_hours(month_total_work), self.settings.hours)
            h_delta = datetime.timedelta(seconds=(h * 60 * 60))

            self.w("Time worked this month: ")
            self.w("%d days %s" % (d, format_duration(h_delta)), "duration")
            # TODO: it'd be nice if this fetched holidays from Chronophage, but
            # I have no idea if there's API for that.
            self.w(" (out of ")
            self.w("%d" % self.weekdays_in_month(), "time")
            self.w(" days)\n")

            # Find out the last day of the previous month.
            first_of_current = self.timelog.day.replace(day=1)
            month_ago = first_of_current - datetime.timedelta(days=1)

            monthly_window = self.monthly_window(month_ago)
            month_total_work, _ = monthly_window.totals()
            (d, h) = divmod(as_hours(month_total_work), self.settings.hours)
            h_delta = datetime.timedelta(hours=h)
            self.w("Time worked last month: ")
            self.w("%d days %s" % (d, format_duration(h_delta)), "duration")
            self.w(" (out of ")
            self.w("%d" % self.weekdays_in_month(month_ago), "time")
            self.w(" days)")

        if self.settings.show_office_hours:
            self.w("\nAt office today: ")
            hours = datetime.timedelta(hours=self.settings.hours)
            total = total_slacking + total_work
            self.w("%s " % format_duration(total), "duration")
            self.w("(")
            if total > hours:
                self.w(format_duration(total - hours), "duration")
                self.w(" overtime")
            else:
                self.w(format_duration(hours - total), "duration")
                self.w(" left")
            self.w(")")

        # We poke the user about having last week's logging fixed up
        # at the beginning of each week, unless we're about to start a
        # new month, in which case we poke the user about last month.
        if (
            self.monthly_window().count_days() < 5
            and not self.monthly_report_reminder_set
            and not self.monthly_report_reminder_acked
        ):
            self.clear_reminders()
            msg = (
                "<b><big>"
                + "Please check your time log for last month."
                + "</big></b>\n\n"
                + "It must be accurate for billing. "
                + "Please make any changes today and submit."
            )
            self.push_reminder(
                msg, self.ack_monthly_reminder, "Edit timelog", self.edit_timelog
            )
            self.monthly_report_reminder_set = True
        elif (
            as_hours(week_total_work) > 3
            and not self.weekly_report_reminder_set
            and not self.weekly_report_reminder_acked
            and not self.monthly_report_reminder_set
        ):
            msg = (
                "<b><big>"
                + "Please check your time log for last week."
                + "</big></b>\n\n"
                + "It must be accurate for estimating invoices purposes. "
                + "Please make any changes today and submit."
            )
            self.push_reminder(
                msg, self.ack_weekly_reminder, "Edit timelog", self.edit_timelog
            )
            self.weekly_report_reminder_set = True

        if monthly_window.parse_error:
            self.push_error_infobar(secondary=str(monthly_window.parse_error))

    def time_left_at_work(self, total_work):
        """Calculate time left to work."""
        last_time = self.timelog.window.last_time()
        if last_time is None:
            return None
        now = datetime.datetime.now(TZOffset())
        current_task = self.task_entry.get_text()
        current_task_time = now - last_time
        if "**" in current_task:
            total_time = total_work
        else:
            total_time = total_work + current_task_time
        return datetime.timedelta(hours=self.settings.hours) - total_time

    def entry_is_valid(self, entry):
        parts = entry.split(":", 4)

        # All entries have 4 task identifiers, and a detail, but not
        # always the detail! So as a first step, check we have at
        # least 4 parts.
        if len(parts) < 4:
            return False

        parts = [part.strip().lower() for part in parts]

        try:
            task_list = self.tasks_dict
        except AttributeError:
            self.update_tasks_dict()
            task_list = self.tasks_dict

        # If we can go into the dictionary using our parts, it's
        # because this is a valid entry
        try:
            dummy = task_list[parts[0]]
            dummy = dummy[parts[1]]
            dummy = dummy[parts[2]]
            dummy = dummy[parts[3]]
        except KeyError:
            return False

        return True

    def week_time_left_at_work(self, week_total_work):
        """Calculate time left to work for the week."""
        last_time = self.timelog.window.last_time()
        if last_time is None:
            return None
        now = datetime.datetime.now(TZOffset())
        current_task = self.task_entry.get_text()
        current_task_time = now - last_time
        if "**" in current_task:
            total_time = week_total_work
        else:
            total_time = week_total_work + current_task_time
        return datetime.timedelta(hours=self.settings.hours * 5) - total_time

    def write_item(self, item):
        buffer = self.log_buffer
        start, stop, duration, entry = item
        self.w(format_duration(duration), "duration")
        start_string = start.astimezone(TZOffset()).strftime("%H:%M")
        stop_string = stop.astimezone(TZOffset()).strftime("%H:%M")
        assert "(" not in start_string
        period = "\t(%s-%s)\t" % (start_string, stop_string)

        self.w(period, "time")

        # We only consider entries with duration != 0 to be invalid,
        # because our first entry is an arrival message, which can be
        # invalid
        if "**" in entry:
            tag = "slacking"
        elif not self.entry_is_valid(entry) and duration.seconds != 0:
            tag = "invalid"
        else:
            tag = None

        self.w(entry + "\n", tag)
        where = buffer.get_end_iter()
        where.backward_cursor_position()
        buffer.place_cursor(where)

    def write_group(self, entry, duration):
        self.w(format_duration(duration), "duration")
        tag = "**" in entry and "slacking" or None
        self.w("\t" + entry + "\n", tag)

    def scroll_to_end(self):
        buffer = self.log_view.get_buffer()
        end_mark = buffer.create_mark("end", buffer.get_end_iter())
        self.log_view.scroll_to_mark(end_mark, 0, False, 0.5, 0.5)
        buffer.delete_mark(end_mark)

    def update_tasks_dict(self):
        task_list = {}
        self.task_store.clear()
        for item in self.tasks.items:
            parent = task_list
            for pos in (s.strip() for s in item.split(":")):
                # Prevent blank labels caused by :: in config
                if not pos:
                    continue
                if pos not in parent:
                    parent[pos] = {}
                parent = parent[pos]
        self.tasks_dict = task_list

    def set_up_task_list(self):
        """Set up a fully hierarchical task list
        Creates a dictionary of dictionaries that mirrors the
        structure of the tasks (separated by :) and then
        recurses into that structure bunging it into the treeview
        """
        self._block_row_toggles += 1
        self.update_tasks_dict()

        def recursive_append(source, prefix, parent, parent_is_unavailable):
            all_unavailable = True

            for key, subtasks in sorted(source.items()):
                is_unavailable = parent_is_unavailable or (key[0] == "*")

                if key[0] == "*":
                    key = key[1:]

                if subtasks == {}:
                    child = self.task_store.append(
                        parent, (key, prefix + key, is_unavailable)
                    )
                else:
                    child = self.task_store.append(
                        parent, (key, prefix + key + ": ", is_unavailable)
                    )
                    all_subtasks_unavailable = recursive_append(
                        subtasks, prefix + key + ": ", child, is_unavailable
                    )

                    if all_subtasks_unavailable:
                        self.task_store.set_value(
                            child, MainWindow.COL_TASK_UNAVAILABLE, True
                        )
                        is_unavailable = True

                if not is_unavailable:
                    all_unavailable = False

            return all_unavailable

        recursive_append(self.tasks_dict, "", None, False)

        self.update_toggle_state()
        self._block_row_toggles -= 1

        # Tasks may have changed, so we may need to reconsider some of
        # the entries as being valid, so populate the log
        self.populate_log()

    def update_toggle_state(self):
        # Use the on-disk toggle state to work out whether a row is expanded
        # or not
        def update_toggle(model, path, iter, togglesdict):
            item = model.get_value(iter, 1)
            # expand the row if we know nothing about it, or its marked
            # for expansion
            if item not in togglesdict or togglesdict[item]:
                self.task_list.expand_row(path, False)

        self._block_row_toggles += 1
        togglesdict = self.load_task_store_toggle_state()
        self.task_store.foreach(update_toggle, togglesdict)
        self._block_row_toggles -= 1

    def set_up_history(self):
        """Set up history."""
        self.history = self.timelog.history
        self.filtered_history = []
        self.history_pos = 0
        self.history_undo = ""
        if not self.have_completion:
            return

        now = datetime.datetime.now(TZOffset())
        history = self.timelog.whole_history()
        count = {}

        for start, stop, duration, entry in history.all_entries():
            delta = now - stop
            if delta.days > 90:
                continue
            weight = 1.0 / (delta.days + 1)
            if entry not in count:
                count[entry] = weight
            else:
                count[entry] += weight

        self.completion_choices.clear()
        for entry, weight in list(count.items()):
            self.completion_choices.append([entry, weight])

    def push_error_infobar(self, primary=None, secondary=None, handler=None):
        if primary is None:
            primary = "Bad entries in your timelog"
        if secondary is None:
            secondary = (
                "Some entries in your timesheet are not known to the server. "
                "Please correct them, and submit."
            )
        message = "<b><big>%s</big></b>\n\n%s" % (
            GLib.markup_escape_text(primary),
            GLib.markup_escape_text(secondary),
        )

        self.push_reminder(
            message, None, "View problems", handler=handler, kind=Gtk.MessageType.ERROR
        )

    def push_reminder(
        self,
        msg,
        close_handler=None,
        action_label=None,
        handler=None,
        kind=Gtk.MessageType.INFO,
    ):
        self.reminders.append(
            {
                "msg": msg,
                "close_handler": close_handler,
                "action_label": action_label,
                "handler": handler,
                "kind": kind,
            }
        )
        self.update_reminder()

    def clear_reminders(self):
        # don’t remove errors
        self.reminders = [
            r for r in self.reminders if r["kind"] == Gtk.MessageType.ERROR
        ]
        self.update_reminder()

    def reminder_response_cb(self, infobar, response, reminder):
        if response == Gtk.ResponseType.OK:
            if reminder["handler"]:
                reminder["handler"]()

        if reminder["close_handler"]:
            reminder["close_handler"]()

        self.reminders.remove(reminder)
        self.update_reminder()

    def update_reminder(self):
        if self.reminder_infobar is not None:
            self.reminder_infobar.destroy()
            self.reminder_infobar = None

        if not self.reminders:
            return

        # We always present the latest reminder first
        reminder = self.reminders[-1]

        label = Gtk.Label()
        label.set_line_wrap(True)
        label.set_markup(reminder["msg"])

        self.reminder_infobar = Gtk.InfoBar()
        self.reminder_infobar.set_message_type(reminder["kind"])

        self.reminder_infobar.get_content_area().pack_start(label, True, True, 0)

        if reminder["action_label"] and reminder["handler"]:
            self.reminder_infobar.add_button(
                reminder["action_label"], Gtk.ResponseType.OK
            )

        self.reminder_infobar.add_button("_Close", Gtk.ResponseType.CLOSE)
        self.reminder_infobar.connect("response", self.reminder_response_cb, reminder)

        self.infobars.pack_start(self.reminder_infobar, True, True, 0)
        self.reminder_infobar.show_all()

    def completion_match_func(self, completion, key, iter, user_data):
        # Text is autocompleted while typing and the automatically
        # completed text is selected. We don't want the autocompleted
        # text to interfere with the search.
        selection = self.task_entry.get_selection_bounds()
        if selection:
            start, end = selection
            key = key[:start] + key[end:]

        model = completion.get_model()
        text = model.get_value(iter, 0)

        # text can be None when we reload the gtimelog file.
        if not text:
            return False

        # key is already lower case. Why?
        return key in text.lower()

    def set_up_completion(self):
        """Set up autocompletion."""
        if not self.settings.enable_gtk_completion:
            self.have_completion = False
            return
        self.have_completion = hasattr(Gtk, "EntryCompletion")
        if not self.have_completion:
            return

        self.completion_choices = Gtk.ListStore(str, float)
        # sort based on weight
        self.completion_choices.set_sort_column_id(1, Gtk.SortType.DESCENDING)

        completion = Gtk.EntryCompletion()
        completion.set_model(self.completion_choices)
        # FIXME: broken in GTK+ -- #575668
        # completion.set_inline_completion (True)
        completion.set_match_func(self.completion_match_func, None)

        def text_func(completion, cell, model, iter, user_data):
            entry = model.get_value(iter, 0)
            text = self.task_entry.get_text()
            selection = self.task_entry.get_selection_bounds()
            if selection:
                start, end = selection
                text = text[:start] + text[end:]

            entry = re.sub(
                "(%s)" % re.escape(text), r"<b>\1</b>", escape(entry), re.IGNORECASE
            )
            cell.set_property("markup", entry)

        completion.set_text_column(0)
        completion.clear()
        # create our own renderer
        renderer = Gtk.CellRendererText()
        completion.pack_start(renderer, True)
        completion.set_cell_data_func(renderer, text_func, None)

        self.task_entry.set_completion(completion)

        # -- DEBUG --
        # renderer = Gtk.CellRendererText()
        # completion.pack_start(renderer, False)
        # completion.set_attributes(renderer, text=1)

        # FIXME: it would be awesome to have a column with a series of **
        # for how good the match is

    def add_history(self, entry):
        """Add an entry to history."""

        self.history.append(entry)
        self.history_pos = 0
        if not self.have_completion:
            return

        match = False
        for row in self.completion_choices:
            if row[0] == entry:
                match = True
                # adjust the weight
                self.completion_choices.set_value(row.iter, 1, row[1] + 1)
                break

        if not match:
            self.completion_choices.append([entry, 1.0])

    def delete_event(self, widget, data=None):
        """Try to close the window."""
        if self.tray_icon:
            self.main_window.hide()
            return True
        else:
            self.quit()
            return False

    def close_about_dialog(self, widget):
        """Ok clicked in the about dialog."""
        self.about_dialog.hide()

    def on_show_activate(self, widget):
        """Tray icon menu -> Show selected"""
        self.main_window.present()

    def on_hide_activate(self, widget):
        """Tray icon menu -> Hide selected"""
        self.main_window.hide()

    def on_quit_activate(self, widget):
        """File -> Quit selected"""
        self.quit()

    def on_about_activate(self, widget):
        """Help -> About selected"""
        self.about_dialog.show()

    def on_online_help_activate(self, widget):
        """Help -> Online Documentation selected"""
        import webbrowser

        webbrowser.open(self.help_url)

    def on_view_today_activate(self, widget):
        self.display_window = TODAY
        self.populate_log()

    def on_view_week_activate(self, widget):
        self.display_window = WEEK
        self.populate_log()

    def on_view_month_activate(self, widget):
        self.display_window = MONTH
        self.populate_log()

    def on_view_last_week_activate(self, widget):
        self.display_window = LAST_WEEK
        self.populate_log()

    def on_view_last_month_activate(self, widget):
        self.display_window = LAST_MONTH
        self.populate_log()

    def on_chronological_activate(self, widget):
        """View -> Chronological"""
        self.chronological = True
        self.populate_log()

    def on_grouped_activate(self, widget):
        """View -> Grouped"""
        self.chronological = False
        self.populate_log()

    def on_daily_report_activate(self, widget):
        """File -> Daily Report"""
        window = self.timelog.window
        self.mail(window.daily_report)

    def on_submit_this_week_menu_activate(self, widget):
        self.submit(self.weekly_window(), True)

    def on_submit_last_week_menu_activate(self, widget):
        day = self.timelog.day - datetime.timedelta(7)
        window = self.weekly_window(day=day)
        self.submit(window, True)

    def on_submit_this_month_menu_activate(self, widget):
        window = self.monthly_window()
        self.submit(window, True)

    def on_submit_last_month_menu_activate(self, widget):
        day = self.timelog.day - datetime.timedelta(self.timelog.day.day)
        window = self.monthly_window(day)
        self.submit(window, True)

    def on_submit_advanced_selection_menu_activate(self, widget):
        self.submit()

    def auto_submit(self):
        day = self.timelog.day

        min = day - datetime.timedelta(30)
        min = datetime.datetime.combine(min, self.timelog.virtual_midnight)
        max = datetime.datetime.combine(day, self.timelog.virtual_midnight)

        timewindow = self.timelog.window_for(min, max)

        self.submit_window.auto_submit_report(timewindow)

    def show_submit_window(self):
        self.submit_window.show()

    def submit(self, window=None, auto_submit=False):
        """Report -> Submit report to server"""

        if window is None:
            window = self.timelog.whole_history()
        self.timelog.reread()
        self.set_up_history()
        self.populate_log()

        if self.settings.report_to_url == "":
            dialog = Gtk.MessageDialog(
                self.main_window,
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                "Incomplete configuration file.",
            )
            dialog.set_title("Error")
            dialog.format_secondary_text(
                'Your configuration file is missing the report_to_url field " + \
                "which is necessary for timesheet uploading.'
            )
            dialog.connect("response", lambda d, i: dialog.destroy())
            dialog.run()
        elif (
            not self.settings.report_to_url.strip().startswith("https")
            and "localhost" not in self.settings.report_to_url
        ):
            dialog = Gtk.MessageDialog(
                self.main_window,
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                "Incomplete configuration file.",
            )
            dialog.set_title("Error")
            dialog.format_secondary_text(
                'Your gtimelogrc is using http " + \
                "(as opposed to https) urls.  Please update your settings.'
            )
            dialog.connect("response", lambda d, i: dialog.destroy())
            dialog.run()
        else:
            self.submit_window.submit(window, auto_submit)

    def on_cancel_submit_button_pressed(self, widget):
        self.submit_window.submitting = False
        self.submit_window.hide()

    def on_yesterdays_report_activate(self, widget):
        """File -> Daily Report for Yesterday"""
        day = self.timelog.day - datetime.timedelta(1)
        window = self.timelog.window_for_day(day)
        self.mail(window.daily_report)

    def on_previous_day_report_activate(self, widget):
        """File -> Daily Report for a Previous Day"""
        day = self.choose_date()
        if day:
            min = datetime.datetime.combine(day, self.timelog.virtual_midnight)
            max = min + datetime.timedelta(1)
            window = self.timelog.window_for(min, max)
            self.mail(window.daily_report)

    def load_task_store_toggle_state(self):
        configdir = os.path.expanduser("~/.gtimelog")
        filename = os.path.join(configdir, "togglesdict.pickle")
        # read the dictionary from disk
        try:
            with open(filename, "rb") as f:
                togglesdict = pickle.load(f)
        except (IOError, pickle.PickleError) as e:
            print("ERROR READING TOGGLE STATE FROM DISK")
            print(e)
            togglesdict = {}

        return togglesdict

    def save_task_store_toggle_state(self, togglesdict):
        configdir = os.path.expanduser("~/.gtimelog")
        filename = os.path.join(configdir, "togglesdict.pickle")
        # write the dictionary back to disk
        try:
            with open(filename, "wb") as f:
                pickle.dump(togglesdict, f)
        except (IOError, pickle.PickleError) as e:
            print("FAILED TO WRITE TOGGLE STATE TO DISK")
            print(e)

    def on_row_expander_changed(self, treeview, iter, path, expanded):
        """Someone toggled a task list expander"""

        if self._block_row_toggles > 0:
            return

        togglesdict = self.load_task_store_toggle_state()
        model = treeview.get_model()
        item = model.get_value(iter, 1)
        togglesdict[item] = expanded
        # FIXME - hypothetically we could look at the togglesdict here to
        # make a guess at the previous toggle state of all of the children
        # of this iter; but I'm not sure that it's super important
        self.save_task_store_toggle_state(togglesdict)

    def choose_date(self):
        """Pop up a calendar dialog.

        Returns either a datetime.date, or one.
        """
        if self.calendar_dialog.run() == Gtk.ResponseType.OK:
            y, m1, d = self.calendar.get_date()
            day = datetime.date(y, m1 + 1, d)
        else:
            day = None
        self.calendar_dialog.hide()
        return day

    def on_calendar_day_selected_double_click(self, widget):
        """Double-click on a calendar day: close the dialog."""
        self.calendar_dialog.response(Gtk.ResponseType.OK)

    def weekly_window(self, day=None):
        if not day:
            day = self.timelog.day
        return self.timelog.window_for_week(day)

    def on_weekly_report_activate(self, widget):
        """File -> Weekly Report"""
        window = self.weekly_window()
        self.mail(window.weekly_report)

    def on_last_weeks_report_activate(self, widget):
        """File -> Weekly Report for Last Week"""
        day = self.timelog.day - datetime.timedelta(7)
        window = self.weekly_window(day=day)
        self.mail(window.weekly_report)

    def on_previous_week_report_activate(self, widget):
        """File -> Weekly Report for a Previous Week"""
        day = self.choose_date()
        if day:
            window = self.weekly_window(day=day)
            self.mail(window.weekly_report)

    def monthly_window(self, day=None):
        if not day:
            day = self.timelog.day
        return self.timelog.window_for_month(day)

    def weekdays_in_month(self, day=None):
        """Counts the weekdays in the month of 'day'. If 'day' is not
        specified, defaults to today."""
        if not day:
            day = self.timelog.day

        c = calendar.Calendar(firstweekday=0)
        weeks = c.monthdayscalendar(day.year, day.month)
        # calendar basically provides Python representations of `cal`.
        # monthdayscalendar returns an array of 7-element arrays representing
        # the weeks of the month. For instance, it looks like this for June
        # 2012:
        #    M   T   W  Th   F  Sa  Su
        #
        # [[ 0,  0,  0,  0,  1,  2,  3],
        #  [ 4,  5,  6,  7,  8,  9, 10],
        #  [11, 12, 13, 14, 15, 16, 17],
        #  [18, 19, 20, 21, 22, 23, 24],
        #  [25, 26, 27, 28, 29, 30, 0]]
        #
        # For each row we look at the first five entries and count how many are
        # non-zero; and then we sum this.
        return sum(sum([1 for x in week[0:5] if x != 0]) for week in weeks)

    def on_previous_month_report_activate(self, widget):
        """File -> Monthly Report for a Previous Month"""
        day = self.choose_date()
        if day:
            window = self.monthly_window(day=day)
            self.mail(window.monthly_report)

    def on_last_month_report_activate(self, widget):
        """File -> Monthly Report for Last Month"""
        day = self.timelog.day - datetime.timedelta(self.timelog.day.day)
        window = self.monthly_window(day=day)
        self.mail(window.monthly_report)

    def on_monthly_report_activate(self, widget):
        """File -> Monthly Report"""
        window = self.monthly_window()
        self.mail(window.monthly_report)

    def _open_spreadsheet(self, history_method):
        with NamedTemporaryFile(
            mode="w+", prefix="gtimelog", suffix=".csv", delete=False
        ) as f:
            tempfn = f.name
            writer = csv.writer(f)
            history = self.timelog.whole_history()
            history_method(history, writer)

        self.spawn(self.settings.spreadsheet, tempfn)

    def on_open_complete_spreadsheet_activate(self, widget):
        """Report -> Complete Report in Spreadsheet"""
        self._open_spreadsheet(TimeWindow.to_csv_complete)

    def on_open_slack_spreadsheet_activate(self, widget):
        """Report -> Work/_Slacking stats in Spreadsheet"""
        self._open_spreadsheet(TimeWindow.to_csv_daily)

    def edit_timelog(self):
        self.spawn(self.settings.editor, self.timelog.filename)

    def on_edit_timelog_activate(self, widget):
        """File -> Edit timelog.txt"""
        self.edit_timelog()

    def on_edit_log_button_clicked(self, widget):
        self.edit_timelog()

    def mail(self, write_draft):
        """Send an email."""
        with NamedTemporaryFile(mode="w+", suffix="gtimelog", delete=False) as draft:
            draftfn = draft.name
            write_draft(draft, self.settings.email, self.settings.name)

        self.spawn(self.settings.mailer, draftfn)
        # XXX rm draftfn when done -- but how?

    def spawn(self, command, arg=None):
        """Spawn a process in background"""
        # XXX shell-escape arg, please.
        if arg is not None:
            if "%s" in command:
                command = command % arg
            else:
                command += " " + arg
        os.system(command + " &")

    def on_reread_activate(self, widget):
        """File -> Reread"""
        self.timelog.reread()
        self.set_up_history()
        self.populate_log()
        self.tick(True)

    def on_show_task_pane_toggled(self, event):
        """View -> Tasks"""
        if self.task_pane.get_property("visible"):
            self.task_pane.hide()
            self.show_unavailable_tasks_item.set_sensitive(False)
        else:
            self.task_pane.show()
            self.show_unavailable_tasks_item.set_sensitive(True)

    def on_show_unavailable_tasks_toggled(self, item):
        self.show_unavailable_tasks = item.get_active()
        self.task_list.get_model().refilter()

    def task_list_row_activated(self, treeview, path, view_column):
        model = treeview.get_model()

        if model.iter_has_child(model.get_iter(path)):
            """A category was clicked: expand or collapse it."""
            if treeview.row_expanded(path):
                treeview.collapse_row(path)
            else:
                treeview.expand_row(path, False)
        else:
            """A task was selected in the task pane -- put it to the entry."""
            task = model[path][MainWindow.COL_TASK_PATH]
            self.task_entry.set_text(task + ": ")
            self.task_entry.grab_focus()
            self.task_entry.set_position(-1)
            # XXX: how does this integrate with history?

    def task_list_button_press(self, menu, event):
        if event.button == 3:
            menu.popup_at_pointer(event)
            return True
        else:
            return False

    def on_task_list_reload(self, event):
        self.tasks.reload()
        self.set_up_task_list()

    def task_list_loading(self):
        self.task_list_loading_failed = False
        self.task_pane_info_label.set_text("Loading...")
        self.task_pane_info_label.show()
        self.task_pane_spinner.start()
        self.task_pane_spinner.show()

    def task_list_error(self, text="Could not get task list."):
        self.task_list_loading_failed = True
        self.task_pane_info_label.set_text(text)
        self.task_pane_info_label.show()

        self.task_pane_spinner.stop()
        self.task_pane_spinner.hide()

    def task_list_loaded(self):
        if not self.task_list_loading_failed:
            self.task_pane_info_label.hide()
            self.set_up_task_list()

            self.task_pane_spinner.stop()
            self.task_pane_spinner.hide()

    def task_entry_changed(self, widget):
        """Reset history position when the task entry is changed."""
        self.history_pos = 0

    def task_entry_key_press(self, widget, event):
        """Handle key presses in task entry."""
        if event.keyval == Gdk.keyval_from_name("Prior"):
            self._do_history(1)
            return True
        if event.keyval == Gdk.keyval_from_name("Next"):
            self._do_history(-1)
            return True
        # XXX This interferes with the completion box.  How do I determine
        # whether the completion box is visible or not?
        if self.have_completion:
            return False
        if event.keyval == Gdk.keyval_from_name("Up"):
            self._do_history(1)
            return True
        if event.keyval == Gdk.keyval_from_name("Down"):
            self._do_history(-1)
            return True
        return False

    def _do_history(self, delta):
        """Handle movement in history."""
        if not self.history:
            return
        if self.history_pos == 0:
            self.history_undo = self.task_entry.get_text()
            self.filtered_history = uniq(
                [entry for entry in self.history if entry.startswith(self.history_undo)]
            )
        history = self.filtered_history
        new_pos = max(0, min(self.history_pos + delta, len(history)))
        if new_pos == 0:
            self.task_entry.set_text(self.history_undo)
            self.task_entry.set_position(-1)
        else:
            self.task_entry.set_text(history[-new_pos])
            self.task_entry.select_region(0, -1)
        # Do this after task_entry_changed reset history_pos to 0
        self.history_pos = new_pos

    def add_entry(self, widget, data=None):
        """Add the task entry to the log."""
        entry = self.task_entry.get_text()
        if not entry:
            return

        if self.inserting_old_time:
            self.insert_new_log_entries()
            now = self.time_before_idle
        else:
            now = None

        self.timelog.append(entry, now)
        if self.chronological:
            self.delete_footer()
            self.write_item(self.timelog.window.last_entry())
            self.add_footer()
            self.scroll_to_end()
        else:
            self.populate_log()
        self.task_entry.set_text("")
        self.task_entry.grab_focus()
        self.tick(True)
        for watcher in self.entry_watchers:
            watcher(entry)

    def resume_from_idle(self):
        """
        Give the user an opportunity to fill in a log entry for the time the
        computer noticed it was idle.

        It is only triggered if the computer was idle
        for > settings.remind_idle period of time
        AND the previous event in the log occurred more than
        settings.remind_idle before the start of the idling
        """

        unlogged_time_before_idle = (
            self.time_before_idle - self.timelog.window.last_time()
        )
        if unlogged_time_before_idle > self.settings.remind_idle:
            resume_notification = Gio.Notification.new("Welcome back")
            resume_notification.set_body(
                "Would you like to insert a log entry near the time you left your computer?"
            )
            resume_notification.add_button(
                "Yes please", "app.on-welcome-back-notification-clicked"
            )
            Gio.Application.get_default().send_notification(
                "resume-notification", resume_notification
            )

    def insert_old_log_entries(self):
        """
        Callback from the resume_from_idle notification
        """
        self.inserting_old_time = True
        self.time_label.set_text(
            "Backdated: " + self.time_before_idle.strftime("%H:%M")
        )

    def insert_new_log_entries(self):
        """
        Record that we inserted an entry.

        Once we have inserted an old log entry, go back to inserting new ones.
        """
        self.inserting_old_time = False
        self.tick(True)  # Reset label caption

    def process_new_day_tasks(self):
        """
        Record that a new day has started, timelog-wise.

        We may need to reset any reminders that were left untouched,
        for one thing.
        """
        if not self.monthly_report_reminder_set:
            self.clear_reminders()
        self.auto_submit()

    def tick(self, force_update=False):
        """Tick every second."""
        now = datetime.datetime.now(TZOffset()).replace(second=0, microsecond=0)

        # Make that every minute
        if now == self.last_tick and not force_update:
            return True

        # Computer has been asleep?
        if self.settings.remind_idle > datetime.timedelta(0):
            if self.last_tick and now - self.last_tick > self.settings.remind_idle:
                self.time_before_idle = self.last_tick
                self.resume_from_idle()

            # Computer has been left idle?
            screensaving = self.screensaver and self.screensaver.GetActive()
            if not screensaving == self.screensaving:
                self.screensaving = screensaving
                if screensaving:
                    self.time_before_idle = self.last_tick
                else:
                    if now - self.time_before_idle > self.settings.remind_idle:
                        self.resume_from_idle()

        # Reload task list if necessary
        if self.tasks.check_reload():
            self.set_up_task_list()

        self.last_tick = now
        last_time = self.timelog.window.last_time()

        if not self.inserting_old_time:
            # We override the text on the label when we are inserting old time
            if last_time is None:
                if self.time_label.get_text() != "Arrival message:":
                    self.time_label.set_text(now.strftime("Arrival message:"))
                    self.process_new_day_tasks()
            else:
                self.time_label.set_text(format_duration(now - last_time))
                # Update "time left to work"
                if not self.lock:
                    self.delete_footer()
                    self.add_footer()
        return True


COL_DATE_OR_DURATION = 0
COL_DESCRIPTION = 1
COL_ACTIVE = 2
COL_ACTIVATABLE = 3
COL_EDITABLE = 4
COL_COLOR = 5
COL_HAS_CHECKBOX = 6
COL_ERROR_MSG = 7


class SubmitWindow(object):
    """The window for submitting reports over the http interface"""

    def __init__(self, tree, settings, application=None):
        self.settings = settings
        self.progress_window = tree.get_object("progress_window")
        self.progressbar = tree.get_object("progressbar")
        tree.get_object("hide_button").connect("clicked", self.hide_progress_window)
        self.window = tree.get_object("submit_window")
        self.main_window = tree.get_object("main_window")
        self.report_url = settings.report_to_url

        tree.get_object("submit_report").connect("clicked", self.on_submit_report)
        self.list_store = self._list_store()
        self.tree_view = tree.get_object("submit_tree")
        self.tree_view.set_model(self.list_store)

        toggle = Gtk.CellRendererToggle()
        toggle.connect("toggled", self.on_toggled)
        tree.get_object("toggle_selection").connect("clicked", self.on_toggle_selection)
        self.tree_view.append_column(
            Gtk.TreeViewColumn(
                "Include?",
                toggle,
                active=COL_ACTIVE,
                activatable=COL_ACTIVATABLE,
                visible=COL_HAS_CHECKBOX,
            )
        )

        time_cell = Gtk.CellRendererText()
        time_cell.set_property("xalign", 1.0)
        time_cell.connect("edited", self.on_time_cell_edit)
        self.tree_view.append_column(
            Gtk.TreeViewColumn(
                "Log Time",
                time_cell,
                text=COL_DATE_OR_DURATION,
                editable=COL_EDITABLE,
                foreground=COL_COLOR,
            )
        )

        item_cell = Gtk.CellRendererText()
        item_cell.connect("edited", self.on_item_cell_edit)
        self.tree_view.append_column(
            Gtk.TreeViewColumn(
                "Log Entry",
                item_cell,
                text=COL_DESCRIPTION,
                editable=COL_EDITABLE,
                foreground=COL_COLOR,
            )
        )

        self.tree_view.append_column(
            Gtk.TreeViewColumn(
                "Error Message",
                Gtk.CellRendererText(),
                text=COL_ERROR_MSG,
                foreground=COL_COLOR,
            )
        )

        selection = self.tree_view.get_selection()
        selection.set_mode(Gtk.SelectionMode.MULTIPLE)

        self.application = application

        self.submitting = False

    def auto_submit_report(self, timewindow):
        if self.submitting:
            return False

        self.submitting = True
        self.timewindow = timewindow
        self.update_submission_list()

        self.do_submit_report(automatic=True)

    def do_submit_report(self, automatic=False):
        """The actual submit action"""
        data = {}
        for row in self.list_store:
            if not row[COL_ACTIVE]:
                continue

            data[row[COL_DATE_OR_DURATION]] = ""
            for item in row.iterchildren():
                duration = format_duration_short(
                    parse_timedelta(item[COL_DATE_OR_DURATION])
                )
                data[row[COL_DATE_OR_DURATION]] += "%s %s\n" % (
                    duration,
                    item[COL_DESCRIPTION],
                )

        self.upload(data, automatic)

    def on_submit_report(self, button):
        self.hide()
        self.show_progress_window()
        self.do_submit_report()

    def progress_window_tick(self):
        self.progressbar.pulse()
        return True

    def show_progress_window(self):
        self.timeout_id = GObject.timeout_add(200, self.progress_window_tick)
        self.progress_window.show()

    def hide_progress_window(self, button=None):
        try:
            GObject.source_remove(self.timeout_id)
        except AttributeError:
            pass  # race condition?

        GObject.idle_add(lambda: self.progress_window.hide())

    def upload_finished(self, session, message, automatic):
        # This is equivalent to the SOUP_STATUS_IS_TRANSPORT_ERROR() macro,
        # which is not exposed via GI (being as it is a macro).
        if (
            message.status_code > Soup.KnownStatusCode.NONE
            and message.status_code < Soup.KnownStatusCode.CONTINUE
        ):
            self.error_dialog(message.reason_phrase, automatic=automatic)
            return

        txt = message.response_body.data

        if message.status_code == 400 or txt.startswith("Failed"):
            # the server didn't like our submission
            self.submitting = False
            self.hide_progress_window()
            self.annotate_failure(txt)

            if automatic:
                self.application.push_error_infobar(
                    handler=self.application.show_submit_window
                )
            else:
                dialog = Gtk.MessageDialog(
                    self.main_window,
                    Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                    Gtk.MessageType.ERROR,
                    Gtk.ButtonsType.OK,
                    "Unable To Upload Timesheet",
                )
                dialog.set_title("Error")
                dialog.format_secondary_text(
                    "Some of the entries in your timesheet refer to tasks that are not known to the server. These entries have been marked in red. Please review them and resubmit to the server when fixed."
                )
                dialog.connect("response", lambda d, i: dialog.destroy())
                self.window.show()
                dialog.show()
        elif message.status_code == 200:
            self.submitting = False
            self.hide()

            if not automatic or self.progress_window.get_property("visible"):
                dialog = Gtk.MessageDialog(
                    self.main_window,
                    Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                    Gtk.MessageType.INFO,
                    Gtk.ButtonsType.OK,
                    "Submitting timesheet succeeded.",
                )
                dialog.set_title("Success")
                dialog.format_secondary_text(
                    "The selected timesheets have been submitted."
                )
                dialog.connect("response", lambda d, i: dialog.destroy())
                dialog.show()
                self.hide_progress_window()
        elif message.status_code == 500:
            # This means an exception on the server.
            # Don't try to stuff a whole django html exception page in the error dialog.
            # It crashes gtk-window-decorator...
            self.error_dialog(
                "Internal server error occurred. Contact the Chronophage maintainer.",
                automatic=automatic,
            )
        else:
            self.error_dialog(txt, automatic=automatic)

    def upload(self, data, automatic):
        if not self.report_url:
            self.error_dialog(
                e="No reporting URL is configured; cannot upload report data.  Check your gtimelogrc settings.",
                title="Configuration Issue",
                automatic=automatic,
            )
            return

        if self.settings.server_cert and not os.path.exists(self.settings.server_cert):
            print("Server certificate file '%s' not found" % self.settings.server_cert)

        message = Soup.Message.new("POST", self.report_url)
        message.request_headers.set_content_type(
            "application/x-www-form-urlencoded", None
        )

        if self.settings.auth_header:
            message.request_headers.append("Authorization", self.settings.auth_header)

        message.request_body.append(urlencode(data).encode())
        message.request_body.complete()
        soup_session.queue_message(message, self.upload_finished, automatic)

    def error_dialog(
        self, e, title="Error Communicating With The Server", automatic=False
    ):
        print(e)
        if automatic:
            self.application.push_error_infobar(
                title, e, handler=self.application.show_submit_window
            )
        else:
            dialog = Gtk.MessageDialog(
                self.window,
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                title,
            )
            dialog.set_title("Error")
            dialog.format_secondary_text("%s" % e)
            dialog.run()
            dialog.destroy()
        self.submitting = False
        self.hide_progress_window()
        self.hide()

    def on_toggled(self, toggle, path):
        """When one of the dates is toggled"""
        value = not self.list_store[path][COL_ACTIVE]
        self.list_store[path] = self.date_row(
            self.list_store[path][COL_DATE_OR_DURATION], value
        )

    def on_toggle_selection(self, toggle):
        """The toggle selection check box to do groups"""
        model, selection = self.tree_view.get_selection().get_selected_rows()
        for row in selection:
            if model[row][COL_ACTIVATABLE]:
                self.on_toggled(toggle, row)

    def on_time_cell_edit(self, cell, path, text):
        """When a time cell has been edited"""
        try:
            time = parse_timedelta(text)
            item = self.list_store[path][COL_DESCRIPTION]
            self.list_store[path] = self.item_row(time, item)
        except ValueError:
            return  # XXX: might want to tell the user what's wrong

    def on_item_cell_edit(self, cell, path, text):
        """When the description cell has been edited"""
        try:
            time = parse_timedelta(self.list_store[path][COL_DATE_OR_DURATION])
            item = text
            self.list_store[path] = self.item_row(time, item)
        except ValueError:
            return  # XXX: might want to tell the user what's wrong

    def update_submission_list(self):
        """Re-read the log file and fill in the list_store"""
        self.list_store.clear()
        date_dict = {}

        regex = re.compile(r": +")
        for start, finish, duration, entry in self.timewindow.all_entries():
            # Trim multiple spaces after separators
            entry = regex.sub(": ", entry).strip()
            # Neatly store the things under the day on which they started
            (date, time) = str(start).split(" ")
            if date not in date_dict:
                date_dict[date] = {}
            if entry not in date_dict[date]:
                date_dict[date][entry] = datetime.timedelta(0)
            date_dict[date][entry] += duration

        keys = sorted(date_dict)
        for date in keys:
            parent = self.list_store.append(None, self.date_row(date))
            # Sort by length of time with longest first
            items = sorted(
                date_dict[date], key=lambda a: date_dict[date][a], reverse=True
            )
            for item in items:
                if date_dict[date][item] > datetime.timedelta(0) and "**" not in item:
                    self.list_store.append(
                        parent, self.item_row(date_dict[date][item], item)
                    )

    def show(self):
        self.window.show()

    def submit(self, timewindow, auto_submit=False):
        """Shows the window with the items included in the given time window, for detailed selection"""
        if self.submitting:
            if not self.window.get_property("visible"):
                self.show_progress_window()
            return

        self.submitting = True
        self.timewindow = timewindow

        self.update_submission_list()

        if auto_submit:
            self.on_submit_report(None)
        else:
            self.window.show()

    # All the row based stuff together
    def _list_store(self):
        """
        date/duration [str],
        description [str],
        active (date submission) [bool],
        activatable [bool],
        editable [bool],
        foreground [str],
        radio [bool],
        error_message [str]
        """
        args = [str, str, bool, bool, bool, str, bool, str]
        # Attempt to stay synced with above index enums
        assert len(args) == COL_ERROR_MSG + 1
        return Gtk.TreeStore(*args)

    def date_row(self, date, submit=True):
        return [date, "", submit, True, False, submit and "black" or "grey", True, ""]

    def item_row(self, duration, item):
        submit = duration > datetime.timedelta(0) and "**" not in item
        return [
            format_duration_long(duration),
            item,
            submit,
            False,
            True,
            submit and "black" or "grey",
            False,
            "",
        ]

    def annotate_failure(self, response):
        """
        Parses the error response sent by the server and adds notes to the treeview
        """
        redate = re.compile(r"\[(\d\d\d\d-\d\d-\d\d)\]")
        reitem = re.compile(r"([^@]*)@\s*\d+:\d\d\s+(.*)$")

        date = "0000-00-00"
        daterow = None
        for line in map(str.strip, response.split("\n")):

            m = redate.match(line)
            if m:
                date = m.group(1)
                for row in self.list_store:
                    if row[COL_DATE_OR_DURATION] == date:
                        daterow = row
                        break
                continue

            m = reitem.match(line)
            if m and daterow:
                for itemrow in daterow.iterchildren():
                    if itemrow[1].strip() == m.group(2):
                        itemrow[COL_COLOR] = "red"
                        daterow[COL_COLOR] = "red"
                        itemrow[COL_ERROR_MSG] = m.group(1).strip()
                continue

            if line and line != "Failed":
                print("Couldn't understand server: %s" % line)

    def hide(self):
        self.window.hide()


def make_option(
    long_name,
    short_name=None,
    flags=0,
    arg=GLib.OptionArg.NONE,
    arg_data=None,
    description=None,
    arg_description=None,
):
    # surely something like this should exist inside PyGObject itself?!
    option = GLib.OptionEntry()
    option.long_name = long_name.lstrip("-")
    option.short_name = 0 if not short_name else short_name.lstrip("-")
    option.flags = flags
    option.arg = arg
    option.arg_data = arg_data
    option.description = description
    option.arg_description = arg_description
    return option


class Application(Gtk.Application):
    def __init__(self, *args, **kwargs):
        super(Application, self).__init__(
            application_id="uk.co.collabora.gtimelog",
        )
        GLib.set_application_name(_("Time Log"))
        GLib.set_prgname("gtimelog")
        self.add_main_option_entries(
            [
                make_option(
                    "--debug", description=_("Show debug information on the console")
                ),
            ]
        )
        self.main_window = None

        self.connect("activate", Application._activate)

    def _activate(self):
        if self.main_window is not None:
            self.main_window.main_window.present()
            return

        try:
            os.makedirs(configdir)  # create it if it doesn't exist
        except OSError:
            pass
        settings = Settings()
        settings_file = os.path.join(configdir, "gtimelogrc")
        if not os.path.exists(settings_file):
            settings.save(settings_file)
        else:
            settings.load(settings_file)
            if settings.server_cert and os.path.exists(settings.server_cert):
                soup_session.set_property("ssl-ca-file", settings.server_cert)
        timelog = TimeLog(
            os.path.join(configdir, "timelog.txt"),
            settings.virtual_midnight,
            settings.autoarrival,
        )
        if settings.task_list_url:
            tasks = RemoteTaskList(
                settings, os.path.join(configdir, "remote-tasks.txt")
            )
        else:
            tasks = TaskList(os.path.join(configdir, "tasks.txt"))
        self.main_window = MainWindow(timelog, settings, tasks)
        self.add_window(self.main_window.main_window)

        self.tray_icon = TrayIcon(self.main_window)
        self.main_window.entry_watchers.append(self.tray_icon.entry_added)

        action = Gio.SimpleAction.new("on-welcome-back-notification-clicked", None)
        action.connect("activate", self.insert_old_log_entries)
        self.add_action(action)

    def insert_old_log_entries(self, notification, arg):
        if self.main_window is not None:
            self.main_window.insert_old_log_entries()


def main():
    """Run the program."""
    mark_time("in main()")

    if len(sys.argv) > 1 and sys.argv[1] == "--sample-config":
        settings = Settings()
        settings.save("gtimelogrc.sample")
        print("Sample configuration file written to gtimelogrc.sample")
        return

    root_logger = logging.getLogger()
    root_logger.addHandler(logging.StreamHandler())
    if DEBUG:
        root_logger.setLevel(logging.DEBUG)
    else:
        root_logger.setLevel(logging.INFO)

    # Tell Python's gettext.gettext() to use our translations
    gettext.bindtextdomain("gtimelog", LOCALE_DIR)
    gettext.textdomain("gtimelog")

    # Tell GTK+ to use out translations
    if hasattr(locale, "bindtextdomain"):
        locale.bindtextdomain("gtimelog", LOCALE_DIR)
        locale.textdomain("gtimelog")
    else:  # pragma: nocover
        # https://github.com/gtimelog/gtimelog/issues/95#issuecomment-252299266
        # locale.bindtextdomain is missing on Windows!
        log.error(_("Unable to configure translations: no locale.bindtextdomain()"))

    # Make ^C terminate the process
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    # Run the app
    app = Application()
    mark_time("app created")
    try:
        sys.exit(app.run(sys.argv))
    finally:
        mark_time("exiting")
    if app.main_window is not None:
        app.main_window.save_ui_state(os.path.join(configdir, "uistaterc"))


if __name__ == "__main__":
    main()
