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

#ifndef ARCIEM_GEOMETRY_H
#define ARCIEM_GEOMETRY_H

#include "math_utils.h"

typedef double angle_t; // radians

extern double const golden_ratio;
extern double const points_per_inch;
extern double const pi;
extern double const pi_over_two;
extern double const two_pi;
extern double const rad2deg;
extern double const deg2rad;

double radians_from_degrees(double deg);
double degrees_from_radians(double rad);

double distance_squared2(double dx, double dy);
double distance_squared4(double x1, double y1, double x2, double y2);

double distance2(double dx, double dy);
double distance4(double x1, double y1, double x2, double y2);

double distance_squared3(double dx, double dy, double dz);
double distance_squared6(double x1, double y1, double z1, double x2, double y2, double z2);

double distance3(double dx, double dy, double dz);
double distance6(double x1, double y1, double z1, double x2, double y2, double z2);

angle_t angle2(double dx, double dy);
angle_t angle4(double x1, double y1, double x2, double y2);
angle_t normalize_angle(angle_t a);

// These versions use parabola segments (hermite curves)
double ease_out_fast(double t);
double ease_in_fast(double t);
double ease_in_and_out_fast(double t);

// These versions use sine curve segments, and are more computationally intensive
double ease_out(double t);
double ease_in(double t);
double ease_in_and_out(double t);

double triangle_up_then_down(double t);
double triangle_down_then_up(double t);

double sawtooth_up(double t);
double sawtooth_down(double t);

double sine_up_then_down(double t);
double sine_down_then_up(double t);
double cosine_up_then_down(double t);
double cosine_down_then_up(double t);

double miter_length(double line_width, double phi);

#endif // ARCIEM_GEOMETRY_H