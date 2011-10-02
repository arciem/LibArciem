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

#ifndef ARCIEM_POINT2_HPP
#define ARCIEM_POINT2_HPP

#include <string>

#include <arciem/geometry/delta2.hpp>
#include <arciem/math_utils.hpp>

namespace arciem {

class area;
class point2i;

class point2 {
public:
	double x, y;

	//
	// constructors
	//
	point2(double x = 0.0, double y = 0.0) : x(x), y(y) { }
	point2(point2i const& p);

	//
	// mutators
	//
	void assign(point2 const& p) { x = p.x; y = p.y; }
	void assign(double x, double y) { this->x = x; this->y = y; }
	
	void assign_x(double x) { this->x = x; }
	void assign_y(double y) { this->y = y; }

	void operator+=(delta2 const& d) { x += d.dx; y += d.dy; }
	inline void operator/=(delta2 const& d) { x /= d.dx; y /= d.dy; }

	//
	// accessors
	//
	point2 set_x(double _x) const { return point2(_x, y); }
	point2 set_y(double _y) const { return point2(x, _y); }
	
	point2 operator+(double n) const { return point2(x + n, y + n); }
	point2 operator-(double n) const { return point2(x - n, y - n); }
	point2 operator+(delta2 const& d) const { return point2(x + d.dx, y + d.dy); }
	point2 operator-(delta2 const& d) const { return point2(x - d.dx, y - d.dy); }
	delta2 operator-(point2 const& p) const { return delta2(x - p.x, y - p.y); }
	point2 operator-() const { return point2(-x, -y); }

	point2 operator*(double n) const { return point2(x * n, y * n); }
	point2 operator/(double n) const { return point2(x / n, y / n); }

	bool operator==(point2 const& p) const { return x == p.x && y == p.y; }
	bool operator!=(point2 const& p) const { return !(*this == p); }

	point2 clamp_inside(area const& a) const;

	point2 interpolate(point2 const& p, double fraction) const {
		return point2( denormalize(fraction, x, p.x), denormalize(fraction, y, p.y) ); }

	double distance(point2 const& p) const { return arciem::distance(p.x - x, p.y - y); }
	double distance_squared(point2 const& p) const { return arciem::distance_squared(p.x - x, p.y - y); }

	double distance(area const& a) const { return distance(clamp_inside(a)); }
	double distance_squared(area const& a) const { return distance_squared(clamp_inside(a)); }
	
	point2 flip_relative_to(area const& a) const;
	point2 integral() const { return point2(floor(x), floor(y)); }
	point2 rotate_relative_to(double angle, point2 const& p) const;

	//
	// pre-defined constants
	//
	static point2 const& zero();

	//
	// debugging
	//
	std::string to_string() const;
};

}

#endif // ARCIEM_POINT2_HPP