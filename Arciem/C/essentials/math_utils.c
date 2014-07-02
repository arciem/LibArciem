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

#include "math_utils.h"

// normalize the given value from the given range into the range 0..1
float normalizef(float value, float min, float max) {
    return (value - min) / (max - min);
}

double normalize(double value, double min, double max) {
    return (value - min) / (max - min);
}

// denormalize the given value from the range 0..1 to the given range
float denormalizef(float value, float min, float max) {
    return value * (max - min) + min;
}

double denormalize(double value, double min, double max) {
    return value * (max - min) + min;
}

// map the value from the first given range to the second given range
float mapf(float value, float min1, float max1, float min2, float max2) {
    return min2 + ((max2 - min2)*(value - min1))/(max1 - min1);
}

double map(double value, double min1, double max1, double min2, double max2) {
    return min2 + ((max2 - min2)*(value - min1))/(max1 - min1);
}

// clamp the value into the given range
float clampf(float value, float min, float max) {
    if(value < min) return min;
    if(value > max) return max;
    return value;
}

double clamp(double value, double min, double max) {
    if(value < min) return min;
    if(value > max) return max;
    return value;
}

// clamp the value into the range [0..1]
float clamp1f(float value) {
    if(value < 0.0) return 0.0;
    if(value > 1.0) return 1.0;
    return value;
}

double clamp1(double value) {
    if(value < 0.0) return 0.0;
    if(value > 1.0) return 1.0;
    return value;
}

// returns fractional part
float fractf(float n) {
	return n - floorf(n);
}

double fract(double n) {
    return n - floor(n);
}

// useful for debugging machine number errors
long long unsigned as_int(double d) {
	long long unsigned i = *(long long unsigned*)&d;
	return i;
}

// Greatest power of 2 less than or equal to x
// From Chapter 3 of the book "Hacker's Delight" by Henry S. Warren
unsigned floor_p2(unsigned x) {
   x = x | (x >>  1); 
   x = x | (x >>  2); 
   x = x | (x >>  4); 
   x = x | (x >>  8); 
   x = x | (x >> 16); 
   return x - (x >> 1); 
} 

// Least power of 2 greater than or equal to x
// From Chapter 3 of the book "Hacker's Delight" by Henry S. Warren
unsigned ceil_p2(unsigned x) {
   x = x - 1; 
   x = x | (x >>  1); 
   x = x | (x >>  2); 
   x = x | (x >>  4); 
   x = x | (x >>  8); 
   x = x | (x >> 16); 
   return x + 1; 
}

float circular_interpolatef(float fraction, float a, float b) {
	if(fabs(b - a) <= 0.5) {
		return denormalizef(fraction, a, b);
	} else {
		float s;
		if(a <= b) {
			s = denormalizef(fraction, a, (float)(b - 1.0));
			if(s < 0.0) s += 1.0;
		} else {
			s = denormalizef(fraction, a, (float)(b + 1.0));
			if(s >= 1.0) s -= 1.0;
		}
		return s;
	}
}

double circular_interpolate(double fraction, double a, double b) {
    if(fabs(b - a) <= 0.5) {
        return denormalize(fraction, a, b);
    } else {
        double s;
        if(a <= b) {
            s = denormalize(fraction, a, (double)(b - 1.0));
            if(s < 0.0) s += 1.0;
        } else {
            s = denormalize(fraction, a, (double)(b + 1.0));
            if(s >= 1.0) s -= 1.0;
        }
        return s;
    }
}
