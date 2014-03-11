/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 *******************************************************************************/

// Portions:
//
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

#ifndef ARCIEM_TIME_UTILS_HPP
#define ARCIEM_TIME_UTILS_HPP

#include <cassert>

#include "config.hpp"
#include "xtime.hpp"

namespace arciem {

typedef double time_point_t; // seconds

const int milliseconds_per_second = 1000;
const int nanoseconds_per_second = 1000000000;
const int nanoseconds_per_millisecond = 1000000;

const int microseconds_per_second = 1000000;
const int nanoseconds_per_microsecond = 1000;

const int seconds_per_minute = 60;
const int minutes_per_hour = 60;
const int hours_per_day = 24;
const int seconds_per_hour = seconds_per_minute * minutes_per_hour;
const int minutes_per_day = minutes_per_hour * hours_per_day;
const int seconds_per_day = seconds_per_minute * minutes_per_day;
const int days_per_week = 7;

enum tense_t {
	tense_past = -1,
	tense_present = 0,
	tense_future = 1
};

inline void to_time(int milliseconds, arciem::xtime& xt)
{
    int res = 0;
    res = arciem::xtime_get(&xt, arciem::TIME_UTC);
    assert(res == arciem::TIME_UTC);

    xt.sec += (milliseconds / milliseconds_per_second);
    xt.nsec += ((milliseconds % milliseconds_per_second) *
        nanoseconds_per_millisecond);

    if (xt.nsec > static_cast<const int>(nanoseconds_per_second))
    {
        ++xt.sec;
        xt.nsec -= nanoseconds_per_second;
    }
}

#if defined(ARCIEM_HAS_PTHREADS)
inline void to_timespec(const arciem::xtime& xt, timespec& ts)
{
    ts.tv_sec = static_cast<int>(xt.sec);
    ts.tv_nsec = static_cast<int>(xt.nsec);
    if(ts.tv_nsec > static_cast<const int>(nanoseconds_per_second))
    {
        ts.tv_sec += ts.tv_nsec / nanoseconds_per_second;
        ts.tv_nsec %= nanoseconds_per_second;
    }
}

inline void to_time(int milliseconds, timespec& ts)
{
    arciem::xtime xt;
    to_time(milliseconds, xt);
    to_timespec(xt, ts);
}

inline void to_timespec_duration(const arciem::xtime& xt, timespec& ts)
{
    arciem::xtime cur;
    int res = 0;
    res = arciem::xtime_get(&cur, arciem::TIME_UTC);
    assert(res == arciem::TIME_UTC);

    if (arciem::xtime_cmp(xt, cur) <= 0)
    {
        ts.tv_sec = 0;
        ts.tv_nsec = 0;
    }
    else
    {
        ts.tv_sec = xt.sec - cur.sec;
        ts.tv_nsec = xt.nsec - cur.nsec;

        if( ts.tv_nsec < 0 )
        {
            ts.tv_sec -= 1;
            ts.tv_nsec += nanoseconds_per_second;
        }
        if(ts.tv_nsec > static_cast<const int>(nanoseconds_per_second))
        {
            ts.tv_sec += ts.tv_nsec / nanoseconds_per_second;
            ts.tv_nsec %= nanoseconds_per_second;
        }
    }
}
#endif

inline void to_duration(arciem::xtime xt, int& milliseconds)
{
    arciem::xtime cur;
    int res = 0;
    res = arciem::xtime_get(&cur, arciem::TIME_UTC);
    assert(res == arciem::TIME_UTC);

    if (arciem::xtime_cmp(xt, cur) <= 0)
        milliseconds = 0;
    else
    {
        if (cur.nsec > xt.nsec)
        {
            xt.nsec += nanoseconds_per_second;
            --xt.sec;
        }
        milliseconds = (int)((xt.sec - cur.sec) * milliseconds_per_second) +
            (((xt.nsec - cur.nsec) + (nanoseconds_per_millisecond/2)) /
                nanoseconds_per_millisecond);
    }
}

inline void to_microduration(const arciem::xtime& xt, int& microseconds)
{
    arciem::xtime cur;
    int res = 0;
    res = arciem::xtime_get(&cur, arciem::TIME_UTC);
    assert(res == arciem::TIME_UTC);

    if (arciem::xtime_get(&cur, arciem::TIME_UTC) <= 0)
        microseconds = 0;
    else
    {
        microseconds = (int)((xt.sec - cur.sec) * microseconds_per_second) +
            (((xt.nsec - cur.nsec) + (nanoseconds_per_microsecond/2)) /
                nanoseconds_per_microsecond);
    }
}

} // namespace

#endif // ARCIEM_TIME_UTILS_HPP
