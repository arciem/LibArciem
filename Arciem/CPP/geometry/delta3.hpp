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

#ifndef ARCIEM_DELTA3_HPP
#define ARCIEM_DELTA3_HPP

#include <string>
#include <cmath>

namespace arciem {

class delta3 {
public:
	double dx, dy, dz;
	
	//
	// constructors
	//
	delta3() : dx(0.0), dy(0.0), dz(0.0) { }
	delta3(double d) : dx(d), dy(d), dz(d) { }
	delta3(double dx, double dy, double dz) : dx(dx), dy(dy), dz(dz) { }
	delta3(delta3 const& d) : dx(d.dx), dy(d.dy), dz(d.dz) { }

	//
	// mutators
	//
	void assign(delta3 const& d) { dx = d.dx; dy = d.dy; dz = d.dz; }
	void assign(double dx, double dy, double dz) { this->dx = dx; this->dy = dy; this->dz = dz; }

	void assign_dx(double dx) { this->dx = dx; }
	void assign_dy(double dy) { this->dy = dy; }
	void assign_dz(double dz) { this->dz = dz; }
	
	void operator+=(delta3 const& d) { dx += d.dx; dy += d.dy; dz += d.dz; }

	void multiply(double n) { dx *= n; dy *= n; dz *= n; }
	void divide(double n) { dx /= n; dy /= n; dz /= n; }

	//
	// accessors
	//
	delta3 set_dx(double _dx) const { return delta3(_dx, dy, dz); }
	delta3 set_dy(double _dy) const { return delta3(dx, _dy, dz); }
	delta3 set_dz(double _dz) const { return delta3(dx, dy, _dz); }

	delta3 operator+(double n) const { return delta3(dx + n, dy + n, dz + n); }
	delta3 operator-(double n) const { return delta3(dx - n, dy - n, dy - n); }
	delta3 operator+(delta3 const& d) const { return delta3(dx + d.dx, dy + d.dy, dz + d.dz); }
	delta3 operator-(delta3 const& d) const { return delta3(dx - d.dx, dy - d.dy, dz - d.dz); }
	delta3 operator-() const { return delta3(-dx, -dy, -dz); }

	delta3 operator*(double n) const { return delta3(dx * n, dy * n, dz * n); }
	delta3 operator/(double n) const { return delta3(dx / n, dy / n, dz / n); }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
	bool operator==(delta3 const& d) const { return dx == d.dx && dy == d.dy && dz == d.dz; }
#pragma clang diagnostic pop
	bool operator!=(delta3 const& d) const { return !(*this == d); }
	
	double volume(void) const { return dx * dy * dz; }

	void multiply(double n, delta3& dst) const { dst.dx = dx * n; dst.dy = dy * n; dst.dz = dz * n; }
	void divide(double n, delta3& dst) const { dst.dx = dx / n; dst.dy = dy / n; dst.dz = dz / n; }
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
	bool equals(delta3 const& d) const { return dx == d.dx && dy == d.dy && dz == d.dz; }
#pragma clang diagnostic pop
	
	double distance() const { return sqrt(dx * dx + dy * dy + dz * dz); }

	double dot(delta3 const& d) const { return dx * d.dx + dy * d.dy + dz * d.dz; }
	delta3 cross(delta3 const& d) const {
		return delta3(
			d.dz * dy - d.dy * dz,
			d.dx * dz - d.dz * dx,
			d.dy * dx - d.dx * dy
		);
	}
	delta3 normalize() const { return (*this) / distance(); }
	delta3 normal(delta3 const&d) const { return cross(d).normalize(); }

	//
	// pre-defined constants
	//
	static delta3 const& zero();
	static delta3 const& x_axis();
	static delta3 const& y_axis();
	static delta3 const& z_axis();

	//
	// debugging
	//
	std::string to_string() const;
};

}

#endif // ARCIEM_DELTA3_HPP