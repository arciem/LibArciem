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

#ifndef ARCIEM_XTIME_H
#define ARCIEM_XTIME_H

#include "config.h"

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

typedef struct
{
    long long sec;
    long nsec;
} xtime;

int xtime_get(xtime* xtp, int clock_type);
int xtime_cmp(const xtime* xt1, const xtime* xt2);

#if 0
class clock : public xtime {
public:
	clock(long long seconds, long nanoseconds) { sec = seconds; nsec = nanoseconds; }
	clock() { xtime_get(this); }
	clock operator-(clock const& c) const;
	double seconds() const;
};
#endif

// Change Log:
//   8 Feb 01  WEKEMPF Initial version.

#endif // ARCIEM_XTIME_H
