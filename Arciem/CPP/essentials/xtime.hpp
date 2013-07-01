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

#ifndef ARCIEM_XTIME_HPP
#define ARCIEM_XTIME_HPP

#include "config.hpp"

namespace arciem {

enum
{
    TIME_UTC=1,
    TIME_TAI,
    TIME_MONOTONIC,
    TIME_PROCESS,
    TIME_THREAD,
    TIME_LOCAL,
    TIME_SYNC,
    TIME_RESOLUTION
};

class xtime
{
public:
    long long sec;
    long nsec;
};

int xtime_get(struct xtime* xtp, int clock_type = TIME_UTC);
inline int xtime_cmp(const xtime& xt1, const xtime& xt2)
{
    int res = (int)(xt1.sec - xt2.sec);
    if (res == 0)
        res = (int)(xt1.nsec - xt2.nsec);
    return res;
}

class clock : public xtime {
public:
	clock(long long seconds, long nanoseconds) { sec = seconds; nsec = nanoseconds; }
	clock() { xtime_get(this); }
	clock operator-(clock const& c) const;
	double seconds() const;
};

} // namespace arciem

// Change Log:
//   8 Feb 01  WEKEMPF Initial version.

#endif // ARCIEM_XTIME_HPP
