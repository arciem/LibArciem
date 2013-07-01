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

#ifndef ARCIEM_MATH_UTILS_HPP
#define ARCIEM_MATH_UTILS_HPP

#include <stddef.h>
#include <cmath>

namespace arciem {

// normalize the given value from the given range into the range 0..1
template<typename T>
inline T normalize(T value, T min, T max)
{
    return (value - min) / (max - min);
}

// denormalize the given value from the range 0..1 to the given range
template<typename T>
inline T denormalize(T value, T min, T max)
{
    return value * (max - min) + min;
}

// map the value from the first given range to the second given range
template<typename T>
inline T map(T value, T min1, T max1, T min2, T max2)
{
    return min2 + ((max2 - min2)*(value - min1))/(max1 - min1);
}

// swap the two values
template<typename T>
inline void swap(T& a, T& b) {
	T t(a);
	a = b;
	b = t;
}

// if min > max, swap the values
template<typename T>
inline void order(T& min, T& max)
{
    if(min > max) {
		swap(min, max);
    }
}

// clamp the value into the given range
template<typename T>
inline T clamp(T value, T min, T max)
{
    if(value < min) return min;
    if(value > max) return max;
    return value;
}

// clamp the value into the range [0..1]
template<typename T>
inline T clamp(T value)
{
    if(value < 0.0) return 0.0;
    if(value > 1.0) return 1.0;
    return value;
}

// compare two values where either or both may be NULL
template<typename T>
bool is_equal(T const* a, T const* b)
{
	if(a == b) return true;
	if(a == NULL || b == NULL) return false;
	return *a == *b;
}

// returns fractional part
template<typename T>
inline T fract(T n)
{
	return n - floor(n);
}

// return -1 for negative, 1 for positive, and 0 for zero values
template<typename T>	
static int sign(T n) {
	if(n < 0) return -1;
	else if(n > 0) return 1;
	else return 0;
}

// useful for debugging machine number errors
inline long long unsigned as_int(double d) {
	long long unsigned i = *(long long unsigned*)&d;
	return i;
}

// Greatest power of 2 less than or equal to x
// From Chapter 3 of the book "Hacker's Delight" by Henry S. Warren
inline unsigned floor_p2(unsigned x) { 
   x = x | (x >>  1); 
   x = x | (x >>  2); 
   x = x | (x >>  4); 
   x = x | (x >>  8); 
   x = x | (x >> 16); 
   return x - (x >> 1); 
} 

// Least power of 2 greater than or equal to x
// From Chapter 3 of the book "Hacker's Delight" by Henry S. Warren
inline unsigned ceil_p2(unsigned x) { 
   x = x - 1; 
   x = x | (x >>  1); 
   x = x | (x >>  2); 
   x = x | (x >>  4); 
   x = x | (x >>  8); 
   x = x | (x >> 16); 
   return x + 1; 
}

template<typename T>
inline T circular_interpolate(T fraction, T a, T b)
{
	if(fabs(b - a) <= 0.5) {
		return denormalize(fraction, a, b);
	} else {
		T s;
		if(a <= b) {
			s = denormalize(fraction, a, (T)(b - 1.0));
			if(s < 0.0) s += 1.0;
		} else {
			s = denormalize(fraction, a, (T)(b + 1.0));
			if(s >= 1.0) s -= 1.0;
		}
		return s;
	}
}

} // namespace

#endif // ARCIEM_MATH_UTILS_HPP
