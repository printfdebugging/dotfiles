import datetime
import time


class TZOffset (datetime.tzinfo):
    ZERO = datetime.timedelta(0)

    def __init__(self, offset=None):
        # offset is an integer in 'hhmm' form. That is, UTC +5.5 = 530
        if offset is not None:
            offset = int(offset)
        else:
            # time.timezone is in seconds back to UTC
            if time.daylight and time.localtime().tm_isdst:
                offset = -time.altzone // 36
            else:
                offset = -time.timezone // 36
            # (offset % 100) needs to be adjusted to be in minutes
            # now (e.g. UTC +5.5 => offset = 550, when it should
            # be 530) - yes, treating hhmm as an integer is a pain
            m = ((offset % 100) * 60) // 100
            offset -= (offset % 100) - m

        self._offset = offset
        h, m = divmod(offset, 100)
        self._offsetdelta = datetime.timedelta(hours=h, minutes=m)

    def utcoffset(self, dt):
        return self._offsetdelta

    def dst(self, dt):
        return self.ZERO

    def tzname(self, dt):
        return str(self._offset)

    def __repr__(self):
        return self.tzname(False)
