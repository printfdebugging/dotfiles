"""
Non-GUI bits of gtimelog.
"""
from __future__ import absolute_import

import codecs
import datetime
import os
import re

from .tzoffset import TZOffset


def as_minutes(duration):
    """Convert a datetime.timedelta to an integer number of minutes."""
    return duration.days * 24 * 60 + duration.seconds // 60


def as_hours(duration):
    """Convert a datetime.timedelta to a float number of hours."""
    return duration.days * 24.0 + duration.seconds / (60.0 * 60.0)


def format_duration(duration):
    """Format a datetime.timedelta with minute precision."""
    h, m = divmod(as_minutes(duration), 60)
    return '%d h %d min' % (h, m)


def format_duration_short(duration):
    """Format a datetime.timedelta with minute precision."""
    h, m = divmod((duration.days * 24 * 60 + duration.seconds // 60), 60)
    return '%d:%02d' % (h, m)


def format_duration_long(duration):
    """Format a datetime.timedelta with minute precision, long format."""
    h, m = divmod((duration.days * 24 * 60 + duration.seconds // 60), 60)
    if h and m:
        return '%d hour%s %d min' % (h, h != 1 and "s" or "", m)
    elif h:
        return '%d hour%s' % (h, h != 1 and "s" or "")
    else:
        return '%d min' % m


def parse_datetime(dt):
    """Parse a datetime instance from 'YYYY-MM-DD HH:MM' formatted string."""
    m = re.match(
        r'^(?P<year>\d+)-(?P<month>\d+)-(?P<day>\d+) '  # date part
        r'(?P<hour>\d+):(?P<min>\d+)(?: (?P<tz>[+-]\d+))?$',  # time part
        dt
    )
    if not m:
        raise ValueError('bad date time: %r' % dt)

    def myint(i):
        if i is not None:
            return int(i)
        else:
            return i

    d = dict((k, myint(v)) for (k, v) in list(m.groupdict().items()))

    # For compat with Python 3, explicitly zero the TZ when missing
    if not m.group('tz'):
        d['tz'] = 0

    return datetime.datetime(d['year'], d['month'], d['day'],
                             d['hour'], d['min'],
                             tzinfo=TZOffset(d['tz']))


def parse_time(t):
    """Parse a time instance from 'HH:MM' formatted string."""
    # FIXME - parse_time should probably support timezones
    m = re.match(r'^(\d+):(\d+)$', t)
    if not m:
        raise ValueError('bad time: %r' % t)
    hour, min = list(map(int, m.groups()))
    return datetime.time(hour, min, tzinfo=TZOffset())


def parse_timedelta(td):
    """
    Parse a timedelta of seconds, minutes, hours and days into a timedelta.

    10s 14h 3d
    14 days 240 MINUTES
    12 hours and 52 d
    1 second 3 min
    1 day and 12 secs
    """
    td = td.strip()
    if td == "" or td == "0":
        return datetime.timedelta(0)

    done = False
    ms = re.search(r'\s*(\d+)\s*s(ec(ond)?(s)?)?', td, re.I)
    if ms:
        seconds = int(ms.group(1))
        done = True
    else:
        seconds = 0

    mm = re.search(r'\s*(\d+)\s*m(in(ute)?(s)?)?(\s*(\d+)\s*$)?', td, re.I)
    if mm:
        seconds += int(mm.group(1)) * 60 + \
            (mm.group(5) and int(mm.group(6)) or 0)
        done = True

    mh = re.search(r'\s*(\d+)\s*h(our(s)?)?(\s*(\d+)\s*$)?', td, re.I)
    if mh:
        seconds += int(mh.group(1)) * 60 * 60 + \
            (mh.group(4) and int(mh.group(5)) * 60 or 0)
        done = True

    if not done:
        m = re.search(r'\s*(\d+)\s*:\s*(\d+)(\s*:\s*(\d+))?', td)
        if m:
            done = True
            seconds = (int(m.group(1)) * 60 + int(m.group(2))) * 60
            if m.group(3):
                seconds += int(m.group(4))
        else:
            seconds = 0

    md = re.search(r'\s*(\d+)\s*d(ay(s)?)?', td, re.I)
    if md:
        days = int(md.group(1))
        done = True
    else:
        days = 0

    if not done:
        raise ValueError('bad timedelta: ', td)
    return datetime.timedelta(days, seconds)


def virtual_day(dt, virtual_midnight):
    """Return the "virtual day" of a timestamp.

    Timestamps between midnight and "virtual midnight" (e.g. 2 am) are
    assigned to the previous "virtual day".
    """
    if dt.timetz() < virtual_midnight:     # assign to previous day
        return dt.date() - datetime.timedelta(1)
    return dt.date()


def different_days(dt1, dt2, virtual_midnight):
    """Check whether dt1 and dt2 are on different "virtual days".

    See virtual_day().
    """
    return virtual_day(dt1, virtual_midnight) != virtual_day(dt2,
                                                             virtual_midnight)


def first_of_month(date):
    """Return the first day of the month for a given date."""
    return date.replace(day=1)


def next_month(date):
    """Return the first day of the next month."""
    if date.month == 12:
        return datetime.date(date.year + 1, 1, 1)
    else:
        return datetime.date(date.year, date.month + 1, 1)


def uniq(items):
    """Return list with consecutive duplicates removed."""
    result = items[:1]
    for item in items[1:]:
        if item != result[-1]:
            result.append(item)
    return result


class TimeWindow(object):
    """A window into a time log.

    Reads a time log file and remembers all events that took place between
    min_timestamp and max_timestamp.  Includes events that took place at
    min_timestamp, but excludes events that took place at max_timestamp.

    self.items is a list of (timestamp, event_title) tuples.

    Time intervals between events within the time window form entries that have
    a start time, a stop time, and a duration.  Entry title is the title of the
    event that occurred at the stop time.

    The first event also creates a special "arrival" entry of zero duration.

    Entries that span virtual midnight boundaries are also converted to
    "arrival" entries at their end point.

    The earliest_timestamp attribute contains the first (which should be the
    oldest) timestamp in the file.
    """

    def __init__(self, filename, min_timestamp=None, max_timestamp=None,
                 virtual_midnight=datetime.time(2, 0, tzinfo=TZOffset()),
                 callback=None):
        """Construct a TimeWindow from a time log filename and options."""
        self.filename = filename
        self.min_timestamp = min_timestamp
        self.max_timestamp = max_timestamp
        self.virtual_midnight = virtual_midnight
        self.parse_error = None
        self.reread(callback)

    def reread(self, callback=None):
        """Parse the time log file and update self.items.

        Also updates self.earliest_timestamp.
        """
        self.items = []
        self.earliest_timestamp = None
        try:
            # accept any file-like object
            # this is a hook for unit tests, really
            if hasattr(self.filename, 'read'):
                f = self.filename
                f.seek(0)
            else:
                f = open(self.filename)
        except IOError:
            return
        line = ''
        self.parse_error = None
        for line in f:
            if ': ' not in line:
                continue
            time, entry = line.split(': ', 1)
            try:
                time = parse_datetime(time)
            except ValueError as e:
                self.parse_error = e
            else:
                entry = entry.strip()
                if callback:
                    callback(entry)
                if self.earliest_timestamp is None:
                    self.earliest_timestamp = time
                if self.min_timestamp and time < self.min_timestamp:
                    continue
                if self.max_timestamp and time >= self.max_timestamp:
                    continue

                if self.items and time <= self.items[-1][0]:
                    self.parse_error = ValueError("This entry out of order: '%s'" % line.strip())
                self.items.append((time, entry))

        # The entries really should be already sorted in the file
        # XXX: instead of quietly resorting them we should inform the user
        self.items.sort()  # there's code that relies on them being sorted
        f.close()
        if self.parse_error:
            print("WARNING: %s" % self.parse_error)

    def last_time(self):
        """Return the time of the last event (or None if there are none)."""
        if not self.items:
            return None
        return self.items[-1][0]

    def all_entries(self):
        """Iterate over all entries.

        Yields (start, stop, duration, entry) tuples.  The first entry
        has a duration of 0.
        """
        stop = None
        for item in self.items:
            start = stop
            stop = item[0]
            entry = item[1]
            if start is None or different_days(start, stop,
                                               self.virtual_midnight):
                start = stop
            duration = stop - start
            yield start, stop, duration, entry

    def count_days(self):
        """Count days that have entries."""
        count = 0
        last = None
        for start, stop, duration, entry in self.all_entries():
            if last is None or different_days(last, start,
                                              self.virtual_midnight):
                last = start
                count += 1
        return count

    def last_entry(self):
        """Return the last entry (or None if there are no events).

        It is always true that

            self.last_entry() == list(self.all_entries())[-1]

        """
        if not self.items:
            return None
        stop = self.items[-1][0]
        entry = self.items[-1][1]
        if len(self.items) == 1:
            start = stop
        else:
            start = self.items[-2][0]
        if different_days(start, stop, self.virtual_midnight):
            start = stop
        duration = stop - start
        return start, stop, duration, entry

    def grouped_entries(self, skip_first=True):
        """Return consolidated entries (grouped by entry title).

        Returns two list: work entries and slacking entries.  Slacking
        entries are identified by finding two asterisks in the title.
        Entry lists are sorted, and contain (start, entry, duration) tuples.
        """
        work = {}
        slack = {}
        for start, stop, duration, entry in self.all_entries():
            if skip_first:
                skip_first = False
                continue
            if '***' in entry:
                continue
            if '**' in entry:
                entries = slack
            else:
                entries = work
            if entry in entries:
                old_start, old_entry, old_duration = entries[entry]
                start = min(start, old_start)
                duration += old_duration
            entries[entry] = (start, entry, duration)
        work = sorted(work.values())
        slack = sorted(slack.values())
        return work, slack

    def totals(self):
        """Calculate total time of work and slacking entries.

        Returns (total_work, total_slacking) tuple.

        Slacking entries are identified by finding two asterisks in the title.

        Assuming that

            total_work, total_slacking = self.totals()
            work, slacking = self.grouped_entries()

        It is always true that

            total_work = sum([duration for start, entry, duration in work])
            total_slacking = sum([duration
                                  for start, entry, duration in slacking])

        (that is, it would be true if sum could operate on timedeltas).
        """
        total_work = total_slacking = datetime.timedelta(0)
        for start, stop, duration, entry in self.all_entries():
            if '**' in entry:
                total_slacking += duration
            else:
                total_work += duration
        return total_work, total_slacking

    def icalendar(self, output):
        """Create an iCalendar file with activities."""
        output.write("BEGIN:VCALENDAR\n")
        output.write("PRODID:-//gtimelog.org/NONSGML GTimeLog//EN\n")
        output.write("VERSION:2.0\n")
        import socket
        idhost = socket.getfqdn()

        dtstamp = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
        for start, stop, duration, entry in self.all_entries():
            summary = (entry
                       .replace('\\', '\\\\')
                       .replace(';', '\\;')
                       .replace(',', '\\,'))
            output.write("BEGIN:VEVENT\n")
            output.write("UID:%s@%s\n" % (hash((start, stop, entry)), idhost))
            output.write("SUMMARY:%s\n" % summary)
            output.write("DTSTART:%s\n" % start.strftime('%Y%m%dT%H%M%S'))
            output.write("DTEND:%s\n" % stop.strftime('%Y%m%dT%H%M%S'))
            output.write("DTSTAMP:%s\n" % dtstamp)
            output.write("END:VEVENT\n")
        output.write("END:VCALENDAR\n")

    def to_csv_complete(self, writer, title_row=True):
        """Export work entries to a CSV file.

        The file has two columns: task title and time (in minutes).
        """
        if title_row:
            writer.writerow(["task", "time (minutes)"])
        work, slack = self.grouped_entries()
        work = sorted((entry, as_minutes(duration))
                      for start, entry, duration in work
                      if duration)  # skip empty "arrival" entries
        writer.writerows(work)

    def to_csv_daily(self, writer, title_row=True):
        """Export daily work, slacking, and arrival times to a CSV file.

        The file has four columns: date, time from midnight til arrival at
        work, slacking, and work (in decimal hours).
        """
        if title_row:
            writer.writerow(["date", "day-start (hours)",
                             "slacking (hours)", "work (hours)"])

        # sum timedeltas per date
        # timelog must be chronological for this to be dependable

        d0 = datetime.timedelta(0)
        days = {}  # date -> [time_started, slacking, work]
        dmin = None
        for start, stop, duration, entry in self.all_entries():
            if dmin is None:
                dmin = start.date()
            day = days.setdefault(start.date(),
                                  [datetime.timedelta(minutes=start.minute,
                                                      hours=start.hour),
                                   d0, d0])
            if '**' in entry:
                day[1] += duration
            else:
                day[2] += duration

        if dmin:
            # fill in missing dates - aka. weekends
            dmax = start.date()
            while dmin <= dmax:
                days.setdefault(dmin, [d0, d0, d0])
                dmin += datetime.timedelta(days=1)

        # convert to hours, and a sortable list
        items = sorted(
            (day, as_hours(start), as_hours(slacking), as_hours(work))
            for day, (start, slacking, work) in list(days.items()))
        writer.writerows(items)

    def daily_report(self, output, email, who):
        """Format a daily report.

        Writes a daily report template in RFC-822 format to output.
        """
        # TODO: refactor this and share code with _report? the logic here is
        # slightly different.

        # Locale is set as a side effect of 'import gtk', so strftime('%a')
        # would give us translated names
        weekday_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        weekday = weekday_names[self.min_timestamp.weekday()]
        week = self.min_timestamp.strftime('%V')
        output.write("To: %(email)s\n" % {'email': email})
        output.write("Subject: %(date)s report for %(who)s"
                     " (%(weekday)s, week %(week)s)\n"
                     % {'date': self.min_timestamp.strftime('%Y-%m-%d'),
                        'weekday': weekday, 'week': week, 'who': who})
        output.write("\n")
        items = list(self.all_entries())
        if not items:
            output.write("No work done today.\n")
            return
        start, stop, duration, entry = items[0]
        entry = entry[:1].upper() + entry[1:]
        output.write("%s at %s\n" % (entry, start.strftime('%H:%M')))
        output.write("\n")
        work, slack = self.grouped_entries()
        total_work, total_slacking = self.totals()
        if work:
            for start, entry, duration in work:
                entry = entry[:1].upper() + entry[1:]
                output.write("%-62s  %s\n" % (entry,
                                              format_duration_long(duration)))
            output.write("\n")
        output.write("Total work done: %s\n" %
                     format_duration_long(total_work))
        output.write("\n")
        if slack:
            for start, entry, duration in slack:
                entry = entry[:1].upper() + entry[1:]
                output.write("%-62s  %s\n" % (entry,
                                              format_duration_long(duration)))
            output.write("\n")
        output.write("Time spent slacking: %s\n" %
                     format_duration_long(total_slacking))

    def weekly_report(self, output, email, who):
        """Format a weekly report.

        Writes a weekly report template in RFC-822 format to output.
        """
        week = self.min_timestamp.strftime('%V')
        output.write("To: %(email)s\n" % {'email': email})
        output.write("Subject: Weekly report for %s (week %s)\n" % (who, week))
        output.write("\n")

        self._report(output, "week")

    def monthly_report(self, output, email, who):
        """Format a monthly report.

        Writes a monthly report template in RFC-822 format to output.
        """
        month = self.min_timestamp.strftime('%Y/%m')
        output.write("To: %(email)s\n" % {'email': email})
        output.write("Subject: Monthly report for %s (%s)\n" % (who, month))
        output.write("\n")

        self._report(output, "month")

    def _report(self, output, period):
        """Format a generic report.

        Writes a report template to output.
        """
        items = list(self.all_entries())
        if not items:
            output.write("No work done this %s.\n" % period)
            return

        output.write("%-62s time\n" % "")

        work, slack = self.grouped_entries()
        total_work, total_slacking = self.totals()
        categories = {}

        if work:
            work = sorted((entry, duration) for start, entry, duration in work)
            for entry, duration in work:
                if not duration:
                    continue  # skip empty "arrival" entries

                entry = entry[:1].upper() + entry[1:]

                if ': ' in entry:
                    cat, task = entry.split(': ', 1)
                    categories[cat] = categories.get(
                        cat, datetime.timedelta(0)) + duration
                else:
                    categories[None] = categories.get(
                        None, datetime.timedelta(0)) + duration

                output.write("%-62s  %s\n" %
                             (entry, format_duration_long(duration)))
            output.write("\n")

        output.write("Total work done this %s: %s\n" %
                     (period, format_duration_long(total_work)))

        if categories:
            output.write("\n")
            output.write("By category:\n")
            output.write("\n")

            for cat, duration in list(categories.items()):
                if not cat:
                    continue

                output.write("%-62s  %s\n" % (
                    cat, format_duration_long(duration)))

            if None in categories:
                output.write("%-62s  %s\n" % (
                    '(none)', format_duration_long(categories[None])))


class TimeLog(object):
    """Time log.

    A time log contains a time window for today, and can add new entries at
    the end.
    """

    def __init__(self, filename, virtual_midnight, autoarrival):
        """Construct from a timelog file and options."""
        self.filename = filename
        self.virtual_midnight = virtual_midnight
        self.autoarrival = autoarrival
        self.reread()

    def virtual_today(self):
        """Return today's date, adjusted for virtual midnight."""
        return virtual_day(datetime.datetime.now(TZOffset()), self.virtual_midnight)

    def reread(self):
        """Reload today's log."""
        self.day = self.virtual_today()
        min = datetime.datetime.combine(self.day, self.virtual_midnight)
        max = min + datetime.timedelta(1)
        self.history = []
        self.window = TimeWindow(self.filename, min, max,
                                 self.virtual_midnight,
                                 callback=self.history.append)
        self.need_space = not self.window.items

    def window_for(self, min, max):
        """Return a TimeWindow for a specified time interval."""
        return TimeWindow(self.filename, min, max, self.virtual_midnight)

    def window_for_day(self, date):
        """Return a TimeWindow for the specified day."""
        min = datetime.datetime.combine(date, self.virtual_midnight)
        max = min + datetime.timedelta(1)
        return self.window_for(min, max)

    def window_for_week(self, date):
        """Return a TimeWindow for the week that contains date."""
        monday = date - datetime.timedelta(date.weekday())
        min = datetime.datetime.combine(monday, self.virtual_midnight)
        max = min + datetime.timedelta(7)
        return self.window_for(min, max)

    def window_for_month(self, date):
        """Return a TimeWindow for the month that contains date."""
        first_of_this_month = first_of_month(date)
        first_of_next_month = next_month(date)
        min = datetime.datetime.combine(first_of_this_month,
                                        self.virtual_midnight)
        max = datetime.datetime.combine(first_of_next_month,
                                        self.virtual_midnight)
        return self.window_for(min, max)

    def whole_history(self):
        """Return a TimeWindow for the whole history."""
        # XXX I don't like this solution.  Better make the min/max filtering
        # arguments optional in TimeWindow.reread
        return self.window_for(self.window.earliest_timestamp,
                               datetime.datetime.now(TZOffset()))

    def raw_append(self, line):
        """Append a line to the time log file."""
        f = codecs.open(self.filename, "a", encoding='UTF-8')
        if self.need_space:
            self.need_space = False
            f.write('\n')
        f.write(line + '\n')
        f.close()

    def append_entry(self, entry, now):
        """Append a line to the time log file."""
        self.window.items.append((now, entry))
        line = '%s: %s' % (now.strftime("%Y-%m-%d %H:%M %z"), entry)
        self.raw_append(line)

    def append(self, entry, now=None):
        """Append a new entry to the time log."""
        if not now:
            now = datetime.datetime.now(TZOffset()).replace(
                second=0, microsecond=0)
        last = self.window.last_time()
        if last and different_days(now, last, self.virtual_midnight):
            # We are working past the virtual midnight. We need to
            # finish the first day, and add an arrival notice at the
            # beginning of the next day, and also reload the log!
            midnight = now.replace(hour=self.virtual_midnight.hour,
                                   minute=self.virtual_midnight.minute)
            one_minute_delta = datetime.timedelta(0, 60)

            if self.autoarrival:
                self.append_entry(entry, midnight - one_minute_delta)
                self.reread()
                self.append_entry('-automatic arrival-',
                                  midnight + one_minute_delta)
            else:
                self.reread()

        self.append_entry(entry, now)


class TaskList(object):
    """Task list.

    You can have a list of common tasks in a text file that looks like this

        Arrived **
        Reading mail
        Project1: do some task
        Project2: do some other task
        Project1: do yet another task

    These tasks are grouped by their common prefix (separated with ':').
    Tasks without a ':' are grouped under "Other".

    A TaskList has an attribute 'groups' which is a list of tuples
    (group_name, list_of_group_items).
    """

    other_title = 'Other'

    loading_callback = None
    loaded_callback = None
    error_callback = None

    def __init__(self, filename):
        """Construct from a filename with tasks."""
        self.filename = filename
        self.load()

    def check_reload(self):
        """Look at the mtime of tasks.txt, and reload it if necessary.

        Returns True if the file was reloaded.
        """
        mtime = self.get_mtime()
        if mtime != self.last_mtime:
            self.load()
            return True
        else:
            return False

    def get_mtime(self):
        """Return the mtime of self.filename.

        Return None if the file doesn't exist.
        """
        try:
            return os.stat(self.filename).st_mtime
        except OSError:
            return None

    def load(self):
        """Load task list from a file named self.filename."""
        self.items = set()
        self.last_mtime = self.get_mtime()
        try:
            with open(self.filename) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#"):
                        self.items.add(line)
        except FileNotFoundError:
            msg = "No existing tasks found at '{}'; starting with empty list"
            print(msg.format(self.filename))

    def reload(self):
        """Reload the task list."""
        self.load()
