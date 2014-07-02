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

#include "geometry.h"

double const golden_ratio = 1.61803398874989484820;
double const points_per_inch = 72.0;
double const pi = M_PI;
double const pi_over_two = M_PI_2;
double const two_pi = 2.0 * M_PI;
double const rad2deg = 180.0 / pi;
double const deg2rad = pi / 180.0;

double radians_from_degrees(double deg) { return deg * deg2rad; }
double degrees_from_radians(double rad) { return rad * rad2deg; }

double distance_squared2(double dx, double dy) { return dx * dx + dy * dy; }
double distance_squared4(double x1, double y1, double x2, double y2) { return distance_squared2(x2 - x1, y2 - y1); }

double distance2(double dx, double dy) { return hypot(dx, dy); }
double distance4(double x1, double y1, double x2, double y2) { return distance2(x2 - x1, y2 - y1); }

double distance_squared3(double dx, double dy, double dz) { return dx * dx + dy * dy + dz * dz; }
double distance_squared6(double x1, double y1, double z1, double x2, double y2, double z2) { return distance_squared3(x2 - x1, y2 - y1, z2 - z1); }

double distance3(double dx, double dy, double dz) { return sqrt(distance_squared3(dx, dy, dz)); }
double distance6(double x1, double y1, double z1, double x2, double y2, double z2) { return sqrt(distance3(x2 - x1, y2 - y1, z2 - z1)); }

angle_t angle2(double dx, double dy) { return atan2(dy, dx); }
angle_t angle4(double x1, double y1, double x2, double y2) { return angle2(x2 - x1, y2 - y1); }
angle_t normalize_angle(angle_t a)
{
	if(a > two_pi) {
		a -= two_pi;
		if (a > two_pi) {
			a = fmod(a, two_pi);
		}
	} else if(a < 0.0) {
		a += two_pi;
		if(a < 0.0) {
			a = fmod(a, two_pi);
		}
	}
	
	return a;
}

// These versions use parabola segments (hermite curves)
double ease_out_fast(double t) { double f = clamp1(t); return 2 * f - f * f; }
double ease_in_fast(double t) { double f = clamp1(t); return f * f; }
double ease_in_and_out_fast(double t) { double f = clamp1(t); return f * f * (3.0 - 2.0 * f); }

// These versions use sine curve segments, and are more computationally intensive
double ease_out(double t) { double f = clamp1(t); return sin(f * pi_over_two); }
double ease_in(double t) { double f = clamp1(t); return 1.0 - cos(f * pi_over_two); }
double ease_in_and_out(double t) { double f = clamp1(t); return 0.5 * (1 + sin(pi * (f - 0.5))); }

double triangle_up_then_down(double t) {
	double f = fract(t);
	return f < 0.5 ? map(f, 0.0, 0.5, 0.0, 1.0) : map(f, 0.5, 1.0, 1.0, 0.0);
}

double triangle_down_then_up(double t) {
	double f = fract(t);
	return f < 0.5 ? map(f, 0.0, 0.5, 1.0, 0.0) : map(f, 0.5, 1.0, 0.0, 1.0);
}

double sawtooth_up(double t) {
	return fract(t);
}

double sawtooth_down(double t) {
	return 1.0 - fract(t);
}

double sine_up_then_down(double t) { return sin(t * two_pi) * 0.5 + 0.5; }
double sine_down_then_up(double t) { return 1.0 - sin(t * two_pi) * 0.5 + 0.5; }
double cosine_up_then_down(double t) { return 1.0 - cos(t * two_pi) * 0.5 + 0.5; }
double cosine_down_then_up(double t) { return cos(t * two_pi) * 0.5 + 0.5; }

double miter_length(double line_width, double phi) { return line_width * (1.0 / sin(phi / 2.0)); }
