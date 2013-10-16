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

#ifndef ARCIEM_DELTA2_HPP
#define ARCIEM_DELTA2_HPP

#include <string>

#include "geometry.hpp"

namespace arciem {

class delta2 {
public:
	double dx, dy;
	
	//
	// constructors
	//
	delta2() : dx(0.0), dy(0.0) { }
	delta2(double dx, double dy) : dx(dx), dy(dy) { }
	delta2(delta2 const& d) : dx(d.dx), dy(d.dy) { }

	//
	// mutators
	//
	void assign(delta2 const& d) { dx = d.dx; dy = d.dy; }
	void assign(double dx, double dy) { this->dx = dx; this->dy = dy; }

	void assign_dx(double dx) { this->dx = dx; }
	void assign_dy(double dy) { this->dy = dy; }
	
	void operator+=(delta2 const& d) { dx += d.dx; dy += d.dy; }
	inline void operator/=(delta2 const& d) { dx /= d.dx; dy /= d.dy; }

	//
	// accessors
	//
	delta2 set_dx(double _dx) const { return delta2(_dx, dy); }
	delta2 set_dy(double _dy) const { return delta2(dx, _dy); }

	delta2 operator+(double n) const { return delta2(dx + n, dy + n); }
	delta2 operator-(double n) const { return delta2(dx - n, dy - n); }
	delta2 operator+(delta2 const& d) const { return delta2(dx + d.dx, dy + d.dy); }
	delta2 operator-(delta2 const& d) const { return delta2(dx - d.dx, dy - d.dy); }
	delta2 operator-() const { return delta2(-dx, -dy); }

	delta2 operator*(double n) const { return delta2(dx * n, dy * n); }
	delta2 operator/(double n) const { return delta2(dx / n, dy / n); }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
	bool operator==(delta2 const& d) const { return dx == d.dx && dy == d.dy; }
#pragma clang diagnostic pop
	bool operator!=(delta2 const& d) const { return !(*this == d); }
	
	double area(void) const { return dx * dy; }

	double dot(delta2 const& d) const { return dx * d.dx + dy * d.dy; }
	
	double distance() const { return arciem::distance(dx, dy); }
	double distance_squared() const { return arciem::distance_squared(dx, dy); }
	double angle() const { return atan2(dy, dx); }
	delta2 normalize() const { return (*this) / distance(); }
	
	bool empty() const { return dx <= 0.0 || dy <= 0.0; }
	delta2 add_quarter_rotation() const { return delta2(-dy, dx); }
	delta2 subtract_quarter_rotation() const { return delta2(dy, -dx); }
	delta2 half_rotation() const { return delta2(-dx, -dy); }
	delta2 negate() const { return delta2(-dx, -dy); }
	delta2 rotate(double angle) const;
	delta2 integral() const;

	//
	// utilities
	//
	static delta2 from_polar(double r, double theta);

	//
	// pre-defined constants
	//
	static delta2 const& zero();

	//
	// debugging
	//
	std::string to_string() const;
};

}

#endif // ARCIEM_DELTA2_HPP