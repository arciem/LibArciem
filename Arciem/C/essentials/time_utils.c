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

#include "time_utils.h"

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

void to_time(int milliseconds, xtime* xt)
{
    xtime_get(xt, TIME_UTC);
    
    xt->sec += (milliseconds / milliseconds_per_second);
    xt->nsec += ((milliseconds % milliseconds_per_second) *
                 nanoseconds_per_millisecond);
    
    if (xt->nsec > (const int)nanoseconds_per_second)
    {
        ++xt->sec;
        xt->nsec -= nanoseconds_per_second;
    }
}

#if defined(ARCIEM_HAS_PTHREADS)
void to_timespec(const xtime& xt, timespec& ts)
{
    ts.tv_sec = static_cast<int>(xt.sec);
    ts.tv_nsec = static_cast<int>(xt.nsec);
    if(ts.tv_nsec > static_cast<const int>(nanoseconds_per_second))
    {
        ts.tv_sec += ts.tv_nsec / nanoseconds_per_second;
        ts.tv_nsec %= nanoseconds_per_second;
    }
}

void to_time(int milliseconds, timespec& ts)
{
    xtime xt;
    to_time(milliseconds, xt);
    to_timespec(xt, ts);
}

void to_timespec_duration(const xtime& xt, timespec& ts)
{
    xtime cur;
    int res = 0;
    res = xtime_get(&cur, TIME_UTC);
    assert(res == TIME_UTC);
    
    if (xtime_cmp(xt, cur) <= 0)
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

void to_duration(xtime *xt, int* milliseconds)
{
    xtime cur;
    xtime_get(&cur, TIME_UTC);
    
    if (xtime_cmp(xt, &cur) <= 0)
        *milliseconds = 0;
    else
    {
        if (cur.nsec > xt->nsec)
        {
            xt->nsec += nanoseconds_per_second;
            --xt->sec;
        }
        *milliseconds = (int)(((xt->sec - cur.sec) * milliseconds_per_second) +
                              (((xt->nsec - cur.nsec) + (nanoseconds_per_millisecond/2)) /
                               nanoseconds_per_millisecond));
    }
}

void to_microduration(const xtime *xt, int *microseconds)
{
    xtime cur;
    xtime_get(&cur, TIME_UTC);
    
    if (xtime_get(&cur, TIME_UTC) <= 0)
        microseconds = 0;
    else
    {
        *microseconds = (int)(((xt->sec - cur.sec) * microseconds_per_second) +
                              (((xt->nsec - cur.nsec) + (nanoseconds_per_microsecond/2)) /
                               nanoseconds_per_microsecond));
    }
}
