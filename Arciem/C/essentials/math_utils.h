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

#ifndef ARCIEM_MATH_UTILS_H
#define ARCIEM_MATH_UTILS_H

#include <stddef.h>
#include <math.h>

// normalize the given value from the given range into the range 0..1
float normalizef(float value, float min, float max);
double normalize(double value, double min, double max);

// denormalize the given value from the range 0..1 to the given range
float denormalizef(float value, float min, float max);
double denormalize(double value, double min, double max);

// map the value from the first given range to the second given range
float mapf(float value, float min1, float max1, float min2, float max2);
double map(double value, double min1, double max1, double min2, double max2);

// clamp the value into the given range
float clampf(float value, float min, float max);
double clamp(double value, double min, double max);

// clamp the value into the range [0..1]
float clamp1f(float value);
double clamp1(double value);

// returns fractional part
float fractf(float n);
double fract(double n);

// useful for debugging machine number errors
long long unsigned as_int(double d);

// Greatest power of 2 less than or equal to x
// From Chapter 3 of the book "Hacker's Delight" by Henry S. Warren
unsigned floor_p2(unsigned x);

// Least power of 2 greater than or equal to x
// From Chapter 3 of the book "Hacker's Delight" by Henry S. Warren
unsigned ceil_p2(unsigned x);

float circular_interpolatef(float fraction, float a, float b);
double circular_interpolate(double fraction, double a, double b);

#endif // ARCIEM_MATH_UTILS_H
