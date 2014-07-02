// Copyright (C) 2001-2003
// William E. Kempf
//
// Permission to use, copy, modify, distribute and sell this software
// and its documentation for any purpose is hereby granted without fee,
// provided that the above copyright notice appear in all copies and
// that both that copyright notice and this permission notice appear
// in supporting documentation.  William E. Kempf makes no representations
// about the suitability of this software for any purpose.
// It is provided "as is" without express or implied warranty.

#include "xtime.h"

#if defined(ARCIEM_HAS_FTIME)
#   include <windows.h>
#elif defined(ARCIEM_HAS_GETTIMEOFDAY)
#   include <sys/time.h>
#elif defined(ARCIEM_HAS_MPTASKS)
#   include <DriverServices.h>
#   include <arciem/cpp/thread/detail/force_cast.hpp>
#endif

#include "time_utils.h"

#ifdef ARCIEM_HAS_MPTASKS

using thread::force_cast;

struct startup_time_info
{
    startup_time_info()
    {
        // 1970 Jan 1 at 00:00:00
        static const DateTimeRec k_sUNIXBase = {1970, 1, 1, 0, 0, 0, 0};
        static unsigned long s_ulUNIXBaseSeconds = 0UL;

        if(s_ulUNIXBaseSeconds == 0UL)
        {
            // calculate the number of seconds between the Mac OS base and the
            // UNIX base the first time we enter this constructor.
            DateToSeconds(&k_sUNIXBase, &s_ulUNIXBaseSeconds);
        }

        unsigned long ulSeconds;

        // get the time in UpTime units twice, with the time in seconds in the
        // middle.
        uint64_t ullFirstUpTime = force_cast<uint64_t>(UpTime());
        GetDateTime(&ulSeconds);
        uint64_t ullSecondUpTime = force_cast<uint64_t>(UpTime());

        // calculate the midpoint of the two UpTimes, and save that.
        uint64_t ullAverageUpTime = (ullFirstUpTime + ullSecondUpTime) / 2ULL;
        m_sStartupAbsoluteTime = force_cast<AbsoluteTime>(ullAverageUpTime);

        // save the number of seconds, recentered at the UNIX base.
        m_ulStartupSeconds = ulSeconds - s_ulUNIXBaseSeconds;
    }

    AbsoluteTime m_sStartupAbsoluteTime;
    UInt32 m_ulStartupSeconds;
};

static startup_time_info g_sStartupTimeInfo;

#endif


int xtime_get(xtime* xtp, int clock_type)
{
    if (clock_type == TIME_UTC)
    {
#if defined(ARCIEM_HAS_FTIME)
        FILETIME ft;
        GetSystemTimeAsFileTime(&ft);
        const uint64_t TIMESPEC_TO_FILETIME_OFFSET =
            ((uint64_t)27111902UL << 32) +
            (uint64_t)3577643008UL;
        xtp->sec = (int)((*(__int64*)&ft - TIMESPEC_TO_FILETIME_OFFSET) /
            10000000);
        xtp->nsec = (int)((*(__int64*)&ft - TIMESPEC_TO_FILETIME_OFFSET -
                              ((__int64)xtp->sec * (__int64)10000000)) * 100);
        return clock_type;
#elif defined(ARCIEM_HAS_GETTIMEOFDAY)
        struct timeval tv;
        gettimeofday(&tv, 0);
        xtp->sec = tv.tv_sec;
        xtp->nsec = tv.tv_usec * 1000;
        return clock_type;
#elif defined(ARCIEM_HAS_CLOCK_GETTIME)
        timespec ts;
        clock_gettime(CLOCK_REALTIME, &ts);
        xtp->sec = ts.tv_sec;
        xtp->nsec = ts.tv_nsec;
        return clock_type;
#elif defined(ARCIEM_HAS_MPTASKS)
        using detail::thread::force_cast;
        // the Mac OS does not have an MP-safe way of getting the date/time,
        // so we use a delta from the startup time.  We _could_ defer this
        // and use something that is interrupt-safe, but this would be _SLOW_,
        // and we need speed here.
        const uint64_t k_ullNanosecondsPerSecond(1000ULL * 1000ULL * 1000ULL);
        AbsoluteTime sUpTime(UpTime());
        uint64_t ullNanoseconds(
            force_cast<uint64_t>(
                AbsoluteDeltaToNanoseconds(sUpTime,
                    detail::g_sStartupTimeInfo.m_sStartupAbsoluteTime)));
        uint64_t ullSeconds = (ullNanoseconds / k_ullNanosecondsPerSecond);
        ullNanoseconds -= (ullSeconds * k_ullNanosecondsPerSecond);
        xtp->sec = detail::g_sStartupTimeInfo.m_ulStartupSeconds + ullSeconds;
        xtp->nsec = ullNanoseconds;
        return clock_type;
#else
#   error "xtime_get implementation undefined"
#endif
    }
    return 0;
}

int xtime_cmp(const xtime* xt1, const xtime* xt2)
{
    int res = (int)(xt1->sec - xt2->sec);
    if (res == 0)
        res = (int)(xt1->nsec - xt2->nsec);
    return res;
}

#if 0
clock clock::operator-(clock const& c) const
{
	long long s = sec - c.sec;
	long n = nsec - c.nsec;
	if(n < 0) {
		s -= 1;
		n += nanoseconds_per_second;
	}
	return clock(s, n);
}

double clock::seconds() const
{
	return static_cast<double>(sec) + static_cast<double>(nsec) / nanoseconds_per_second;
}
#endif

// Change Log:
//   8 Feb 01  WEKEMPF Initial version.
