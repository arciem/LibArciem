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

#ifndef ARCIEM_POINT3_HPP
#define ARCIEM_POINT3_HPP

#include <string>

#include "geometry.hpp"
#include "delta3.hpp"
#include "math_utils.hpp"

namespace arciem {

class volume;
class point2;

class point3 {
public:
	double x, y, z;
	
	//
	// constructors
	//
	point3() : x(0.0), y(0.0), z(0.0) { }
	point3(double x, double y, double z) : x(x), y(y), z(z) { }
	point3(point3 const& p) : x(p.x), y(p.y), z(p.z) { }
	point3(point2 const& p);

	//
	// mutators
	//
	void operator+=(delta3 const& d) { x += d.dx; y += d.dy; z += d.dz; }

	void assign(point3 const& p) { x = p.x; y = p.y; z = p.z; }
	void assign(double x, double y, double z) { this->x = x; this->y = y; this->z = z; }

	void assign_x(double x) { this->x = x; }
	void assign_y(double y) { this->y = y; }
	void assign_z(double z) { this->z = z; }

	void multiply(double n) { x *= n; y *= n; z *= n; }
	void divide(double n) { x /= n; y /= n; z /= n; }
	void negate(void) { x = -x; y = -y; z = -z; }
	void add(delta3 const& d) { x += d.dx; y += d.dy; z += d.dz; }
	void subtract(delta3 const& d) { x -= d.dx; y -= d.dy; z -= d.dz; }

	//
	// accessors
	//
	point3 set_x(double _x) const { return point3(_x, y, z); }
	point3 set_y(double _y) const { return point3(x, _y, z); }
	point3 set_z(double _z) const { return point3(x, y, _z); }

	point3 operator+(double n) const { return point3(x + n, y + n, z + n); }
	point3 operator-(double n) const { return point3(x - n, y - n, z - n); }
	point3 operator+(delta3 const& d) const { return point3(x + d.dx, y + d.dy, z + d.dz); }
	point3 operator-(delta3 const& d) const { return point3(x - d.dx, y - d.dy, z - d.dz); }
	delta3 operator-(point3 const& p) const { return delta3(x - p.x, y - p.y, z - p.z); }
	point3 operator-() const { return point3(-x, -y, -z); }

	point3 operator*(double n) const { return point3(x * n, y * n, z * n); }
	point3 operator/(double n) const { return point3(x / n, y / n, z / n); }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
	bool operator==(point3 const& p) const { return x == p.x && y == p.y && z == p.z; }
#pragma clang diagnostic pop
	bool operator!=(point3 const& p) const { return !(*this == p); }

	void multiply(double n, point3& dst) const { dst.x = x * n; dst.y = y * n; dst.z = z * n; }
	void divide(double n, point3& dst) const { dst.x = x / n; dst.y = y / n; dst.z = z / n; }
	void negate(point3& dst) const { dst.x = -x; dst.y = -y; dst.z = -z; }
	void add(delta3 const& d, point3& dst) const { dst.x = x + d.dx; dst.y = y + d.dy; dst.z = z + d.dz; }
	void subtract(delta3 const& d, point3& dst) const { dst.x = x - d.dx; dst.y = y - d.dy; dst.z = z - d.dz; }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
	bool equals(point3 const& p) const { return x == p.x && y == p.y && z == p.z; }
#pragma clang diagnostic pop
	
	point3 clamp_inside(volume const& v) const;

	point3 interpolate(point3 const& p, double fraction) const {
		return point3( denormalize(fraction, x, p.x), denormalize(fraction, y, p.y) , denormalize(fraction, z, p.z) ); }

	double distance(point3 const& p) const { return arciem::distance(p.x - x, p.y - y, p.z - z); }
	double distance_squared(point3 const& p) const { return arciem::distance_squared(p.x - x, p.y - y, p.z - z); }

	double distance(volume const& v) const { return distance(clamp_inside(v)); }
	double distance_squared(volume const& v) const { return distance_squared(clamp_inside(v)); }

	static delta3 normal(point3 const& p1, point3 const& p2, point3 const& p3) { return (p3 - p2).normal(p1 - p2); }

	//
	// pre-defined constants
	//
	static point3 const& zero();

	//
	// debugging
	//
	std::string to_string() const;
};

}

#endif // ARCIEM_POINT3_HPP