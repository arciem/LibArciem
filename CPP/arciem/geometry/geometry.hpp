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

#ifndef ARCIEM_GEOMETRY_HPP
#define ARCIEM_GEOMETRY_HPP

#include <cmath>
#include <arciem/math_utils.hpp>

namespace arciem {

typedef double angle_t; // radians

double const golden_ratio = 1.61803398874989484820;
double const points_per_inch = 72.0;
double const pi = M_PI;
double const pi_over_two = M_PI_2;
double const two_pi = 2.0 * M_PI;
double const rad2deg = 180.0 / pi;
double const deg2rad = pi / 180.0;

template<typename T>
inline T radians_from_degrees(T deg) { return deg * deg2rad; }
template<typename T>
inline T degrees_from_radians(T rad) { return rad * rad2deg; }

inline double distance_squared(double dx, double dy) { return dx * dx + dy * dy; }
inline double distance_squared(double x1, double y1, double x2, double y2) { return distance_squared(x2 - x1, y2 - y1); }

inline double distance(double dx, double dy) { return hypot(dx, dy); }
inline double distance(double x1, double y1, double x2, double y2) { return distance(x2 - x1, y2 - y1); }

inline double distance_squared(double dx, double dy, double dz) { return dx * dx + dy * dy + dz * dz; }
inline double distance_squared(double x1, double y1, double z1, double x2, double y2, double z2) { return distance_squared(x2 - x1, y2 - y1, z2 - z1); }

inline double distance(double dx, double dy, double dz) { return sqrt(distance_squared(dx, dy, dz)); }
inline double distance(double x1, double y1, double z1, double x2, double y2, double z2) { return sqrt(distance(x2 - x1, y2 - y1, z2 - z1)); }

inline angle_t angle(double dx, double dy) { return std::atan2(dy, dx); }
inline angle_t angle(double x1, double y1, double x2, double y2) { return angle(x2 - x1, y2 - y1); }
angle_t normalize_angle(angle_t a);

// These versions use parabola segments (hermite curves)
inline double ease_out(double t) { double f = clamp(t); return 2 * f - f * f; }
inline double ease_in(double t) { double f = clamp(t); return f * f; }
inline double ease_in_and_out(double t) { double f = clamp(t); return f * f * (3.0 - 2.0 * f); }

// These versions use sine curve segments, and are more computationally intensive
inline double ease_out(double t, int) { double f = clamp(t); return std::sin(f * pi_over_two); }
inline double ease_in(double t, int) { double f = clamp(t); return 1.0 - std::cos(f * pi_over_two); }
inline double ease_in_and_out(double t, int) { double f = clamp(t); return 0.5 * (1 + std::sin(pi * (f - 0.5))); }

inline double triangle_up_then_down(double t) {
	double f = fract(t);
	return f < 0.5 ? map(f, 0.0, 0.5, 0.0, 1.0) : map(f, 0.5, 1.0, 1.0, 0.0);
}

inline double triangle_down_then_up(double t) {
	double f = fract(t);
	return f < 0.5 ? map(f, 0.0, 0.5, 1.0, 0.0) : map(f, 0.5, 1.0, 0.0, 1.0);
}

inline double sawtooth_up(double t) {
	return fract(t);
}

inline double sawtooth_down(double t) {
	return 1.0 - fract(t);
}

inline double sine_up_then_down(double t) { return sin(t * two_pi) * 0.5 + 0.5; }
inline double sine_down_then_up(double t) { return 1.0 - sin(t * two_pi) * 0.5 + 0.5; }
inline double cosine_up_then_down(double t) { return 1.0 - cos(t * two_pi) * 0.5 + 0.5; }
inline double cosine_down_then_up(double t) { return cos(t * two_pi) * 0.5 + 0.5; }

inline double miter_length(double line_width, double phi) { return line_width * (1.0 / std::sin(phi / 2.0)); }

} // namespace

#endif // ARCIEM_GEOMETRY_HPP