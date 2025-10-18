#!/usr/bin/env python3
import os
import sys
from datetime import datetime, time, timedelta, timezone

pkgdir = os.path.join(os.path.dirname(__file__), 'src')
sys.path.insert(0, pkgdir)

from gtimelog.timelog import TimeWindow
from gtimelog.tzoffset import TZOffset

if __name__ == "__main__":
    fn = os.path.expanduser('~/.gtimelog/timelog.txt')
    UTC = timezone(timedelta(hours=0))
    virtual_midnight = time(2, 0, tzinfo=TZOffset())
    with open(fn, 'r', encoding='utf-8') as fp:
        window = TimeWindow(
            fp,
            virtual_midnight=time(4, 0, tzinfo=TZOffset()),
            min_timestamp=datetime(
                2020, 1, 1, tzinfo=TZOffset()))

    for start, stop, duration, entry in window.all_entries():
        print(start, stop, duration, entry)
        if ":" not in entry and "**" not in entry:
            assert (duration == timedelta(hours=0))
