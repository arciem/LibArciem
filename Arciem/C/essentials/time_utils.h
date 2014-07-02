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

#ifndef ARCIEM_TIME_UTILS_H
#define ARCIEM_TIME_UTILS_H

#include "config.h"
#include "xtime.h"

typedef double time_point_t; // seconds

extern const int milliseconds_per_second;
extern const int nanoseconds_per_second;
extern const int nanoseconds_per_millisecond;

extern const int microseconds_per_second;
extern const int nanoseconds_per_microsecond;

extern const int seconds_per_minute;
extern const int minutes_per_hour;
extern const int hours_per_day;
extern const int seconds_per_hour;
extern const int minutes_per_day;
extern const int seconds_per_day;
extern const int days_per_week;

enum tense_t {
	tense_past = -1,
	tense_present = 0,
	tense_future = 1
};

void to_time(int milliseconds, xtime* xt);

#if defined(ARCIEM_HAS_PTHREADS)
void to_timespec(const xtime& xt, timespec& ts);
void to_time(int milliseconds, timespec& ts);
void to_timespec_duration(const xtime& xt, timespec& ts);
#endif

void to_duration(xtime *xt, int* milliseconds);
void to_microduration(const xtime *xt, int *microseconds);

#endif // ARCIEM_TIME_UTILS_H
