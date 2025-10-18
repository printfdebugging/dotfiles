"""Tests for gtimelog.timelog"""

import doctest
import re
import unittest


class Checker(doctest.OutputChecker):
    """Doctest output checker that can deal with unicode literals."""

    def check_output(self, want, got, optionflags):
        # u'...' -> '...'; u"..." -> "..."
        got = re.sub(r'''\bu('[^']*'|"[^"]*")''', r'\1', got)
        # Python 3.7: datetime.timedelta(seconds=1860) ->
        # Python < 3.7: datetime.timedelta(0, 1860)
        got = re.sub(r'datetime[.]timedelta[(]seconds=(\d+)[)]',
                     r'datetime.timedelta(0, \1)', got)
        return doctest.OutputChecker.check_output(self, want, got, optionflags)


def doctest_as_hours():
    """Tests for as_hours

        >>> from gtimelog.timelog import as_hours
        >>> from datetime import timedelta
        >>> as_hours(timedelta(0))
        0.0
        >>> as_hours(timedelta(minutes=30))
        0.5
        >>> as_hours(timedelta(minutes=60))
        1.0
        >>> as_hours(timedelta(days=2))
        48.0

    """


def doctest_format_duration():
    """Tests for format_duration.

        >>> from gtimelog.timelog import format_duration
        >>> from datetime import timedelta
        >>> format_duration(timedelta(0))
        '0 h 0 min'
        >>> format_duration(timedelta(minutes=1))
        '0 h 1 min'
        >>> format_duration(timedelta(minutes=60))
        '1 h 0 min'

    """


def doctest_format_short():
    """Tests for format_duration_short.

        >>> from gtimelog.timelog import format_duration_short
        >>> from datetime import timedelta
        >>> format_duration_short(timedelta(0))
        '0:00'
        >>> format_duration_short(timedelta(minutes=1))
        '0:01'
        >>> format_duration_short(timedelta(minutes=59))
        '0:59'
        >>> format_duration_short(timedelta(minutes=60))
        '1:00'
        >>> format_duration_short(timedelta(days=1, hours=2, minutes=3))
        '26:03'

    """


def doctest_format_duration_long():
    """Tests for format_duration_long.

        >>> from gtimelog.timelog import format_duration_long
        >>> from datetime import timedelta
        >>> format_duration_long(timedelta(0))
        '0 min'
        >>> format_duration_long(timedelta(minutes=1))
        '1 min'
        >>> format_duration_long(timedelta(minutes=60))
        '1 hour'
        >>> format_duration_long(timedelta(minutes=65))
        '1 hour 5 min'
        >>> format_duration_long(timedelta(hours=2))
        '2 hours'
        >>> format_duration_long(timedelta(hours=2, minutes=1))
        '2 hours 1 min'

    """


def doctest_parse_datetime():
    """Tests for parse_datetime

        >>> from gtimelog.timelog import parse_datetime
        >>> parse_datetime('2005-02-03 02:13')
        datetime.datetime(2005, 2, 3, 2, 13, tzinfo=0)
        >>> parse_datetime('2005-02-03 02:13 +0800')
        datetime.datetime(2005, 2, 3, 2, 13, tzinfo=800)
        >>> parse_datetime('2005-02-03 02:13 -0500')
        datetime.datetime(2005, 2, 3, 2, 13, tzinfo=-500)
        >>> parse_datetime('xyzzy')
        Traceback (most recent call last):
          ...
        ValueError: bad date time: 'xyzzy'
        >>> parse_datetime('YYYY-MM-DD HH:MM')
        Traceback (most recent call last):
          ...
        ValueError: bad date time: 'YYYY-MM-DD HH:MM'

    """


def doctest_parse_time():
    """Tests for parse_time

        >>> from gtimelog.timelog import parse_time
        >>> parse_time('02:13')
        datetime.time(2, 13, tzinfo=...)
        >>> parse_time('xyzzy')
        Traceback (most recent call last):
          ...
        ValueError: bad time: 'xyzzy'

    """


def doctest_virtual_day():
    """Tests for virtual_day

        >>> from datetime import datetime, time
        >>> from gtimelog.timelog import virtual_day

    Virtual midnight

        >>> vm = time(2, 0)

    The tests themselves:

        >>> virtual_day(datetime(2005, 2, 3, 1, 15), vm)
        datetime.date(2005, 2, 2)
        >>> virtual_day(datetime(2005, 2, 3, 1, 59), vm)
        datetime.date(2005, 2, 2)
        >>> virtual_day(datetime(2005, 2, 3, 2, 0), vm)
        datetime.date(2005, 2, 3)
        >>> virtual_day(datetime(2005, 2, 3, 12, 0), vm)
        datetime.date(2005, 2, 3)
        >>> virtual_day(datetime(2005, 2, 3, 23, 59), vm)
        datetime.date(2005, 2, 3)

    """


def doctest_different_days():
    """Tests for different_days

        >>> from datetime import datetime, time
        >>> from gtimelog.timelog import different_days

    Virtual midnight

        >>> vm = time(2, 0)

    The tests themselves:

        >>> different_days(datetime(2005, 2, 3, 1, 15),
        ...                datetime(2005, 2, 3, 2, 15), vm)
        True
        >>> different_days(datetime(2005, 2, 3, 11, 15),
        ...                datetime(2005, 2, 3, 12, 15), vm)
        False

    """


def doctest_first_of_month():
    """Tests for first_of_month

        >>> from gtimelog.timelog import first_of_month
        >>> from datetime import date, timedelta

        >>> first_of_month(date(2007, 1, 1))
        datetime.date(2007, 1, 1)

        >>> first_of_month(date(2007, 1, 7))
        datetime.date(2007, 1, 1)

        >>> first_of_month(date(2007, 1, 31))
        datetime.date(2007, 1, 1)

        >>> first_of_month(date(2007, 2, 1))
        datetime.date(2007, 2, 1)

        >>> first_of_month(date(2007, 2, 28))
        datetime.date(2007, 2, 1)

        >>> first_of_month(date(2007, 3, 1))
        datetime.date(2007, 3, 1)

    Why not test extensively?

        >>> d = date(2000, 1, 1)
        >>> while d < date(2005, 1, 1):
        ...     f = first_of_month(d)
        ...     if (f.year, f.month, f.day) != (d.year, d.month, 1):
        ...         print("WRONG: first_of_month(%r) returned %r" % (d, f))
        ...     d += timedelta(1)

    """


def doctest_next_month():
    """Tests for next_month

        >>> from gtimelog.timelog import next_month
        >>> from datetime import date, timedelta

        >>> next_month(date(2007, 1, 1))
        datetime.date(2007, 2, 1)

        >>> next_month(date(2007, 1, 7))
        datetime.date(2007, 2, 1)

        >>> next_month(date(2007, 1, 31))
        datetime.date(2007, 2, 1)

        >>> next_month(date(2007, 2, 1))
        datetime.date(2007, 3, 1)

        >>> next_month(date(2007, 2, 28))
        datetime.date(2007, 3, 1)

        >>> next_month(date(2007, 3, 1))
        datetime.date(2007, 4, 1)

    Why not test extensively?

        >>> d = date(2000, 1, 1)
        >>> while d < date(2005, 1, 1):
        ...     f = next_month(d)
        ...     prev = f - timedelta(1)
        ...     if f.day != 1 or (prev.year, prev.month) != (d.year, d.month):
        ...         print("WRONG: next_month(%r) returned %r" % (d, f))
        ...     d += timedelta(1)

    """


def doctest_uniq():
    """Tests for uniq

        >>> from gtimelog.timelog import uniq
        >>> uniq(['a', 'b', 'b', 'c', 'd', 'b', 'd'])
        ['a', 'b', 'c', 'd', 'b', 'd']
        >>> uniq(['a'])
        ['a']
        >>> uniq([])
        []

    """


def doctest_TimeWindow_monthly_report():
    r"""Tests for TimeWindow.monthly_report

        >>> import sys

        >>> from datetime import datetime, time
        >>> from gtimelog.timelog import TimeWindow, TZOffset

        >>> vm = time(2, 0, tzinfo=TZOffset())
        >>> min = datetime(2007, 9, 1, tzinfo=TZOffset())
        >>> max = datetime(2007, 10, 1, tzinfo=TZOffset())

        >>> from io import StringIO

        >>> sampledata = StringIO('')
        >>> window = TimeWindow(sampledata, min, max, vm)
        >>> window.monthly_report(sys.stdout, 'foo@bar.com', 'Bob Jones')
        To: foo@bar.com
        Subject: Monthly report for Bob Jones (2007/09)
        <BLANKLINE>
        No work done this month.

        >>> sampledata = StringIO('''
        ... 2007-09-30 09:00: start
        ... 2007-09-30 09:23: Bing: stuff
        ... 2007-09-30 12:54: Bong: other stuff
        ... 2007-09-30 13:32: lunch **
        ... 2007-09-30 15:46: misc
        ... ''')

        >>> window = TimeWindow(sampledata, min, max, vm)
        >>> window.monthly_report(sys.stdout, 'foo@bar.com', 'Bob Jones')
        To: foo@bar.com
        Subject: Monthly report for Bob Jones (2007/09)
        <BLANKLINE>
                                                                        time
        Bing: stuff                                                     23 min
        Bong: other stuff                                               3 hours 31 min
        Misc                                                            2 hours 14 min
        <BLANKLINE>
        Total work done this month: 6 hours 8 min
        <BLANKLINE>
        By category:
        <BLANKLINE>
        Bing                                                            23 min
        Bong                                                            3 hours 31 min
        (none)                                                          2 hours 14 min
        <BLANKLINE>

    """


def doctest_TimeWindow_to_csv_daily():
    r"""Tests for TimeWindow.to_csv_daily

        >>> from gtimelog.timelog import TZOffset
        >>> from datetime import datetime, time
        >>> min = datetime(2008, 6, 1, tzinfo=TZOffset())
        >>> max = datetime(2008, 7, 1, tzinfo=TZOffset())
        >>> vm = time(2, 0, tzinfo=TZOffset())

        >>> from io import StringIO

        >>> sampledata = StringIO('''
        ... 2008-06-03 12:45: start
        ... 2008-06-03 13:00: something
        ... 2008-06-03 14:45: something else
        ... 2008-06-03 15:45: etc
        ... 2008-06-05 12:45: start
        ... 2008-06-05 13:15: something
        ... ''')

        >>> from gtimelog.timelog import TimeWindow
        >>> window = TimeWindow(sampledata, min, max, vm)

        >>> import sys
        >>> import csv
        >>> window.to_csv_daily(csv.writer(sys.stdout))
        date,day-start (hours),slacking (hours),work (hours)
        2008-06-03,12.75,0.0,3.0
        2008-06-04,0.0,0.0,0.0
        2008-06-05,12.75,0.0,0.5

    """


def additional_tests(): # for setup.py
    return doctest.DocTestSuite(optionflags=doctest.NORMALIZE_WHITESPACE | doctest.ELLIPSIS,
                                checker=Checker())


def test_suite():
    return unittest.TestSuite([
        unittest.defaultTestLoader.loadTestsFromName(__name__),
        additional_tests(),
    ])
