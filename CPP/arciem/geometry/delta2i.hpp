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

#ifndef ARCIEM_DELTA2I_HPP
#define ARCIEM_DELTA2I_HPP

#include <string>

#include <arciem/geometry/geometry.hpp>

namespace arciem {

class delta2;

class delta2i {
public:
	int dx, dy;
	
	delta2i() : dx(0), dy(0) { }
	delta2i(int dx, int dy) : dx(dx), dy(dy) { }
	delta2i(const delta2i& d) : dx(d.dx), dy(d.dy) { }
	explicit delta2i(const delta2& d);

	delta2i operator+(int n) const { return delta2i(dx + n, dy + n); }
	delta2i operator-(int n) const { return delta2i(dx - n, dy - n); }
	delta2i operator+(delta2i const& d) const { return delta2i(dx + d.dx, dy + d.dy); }
	delta2i operator-(delta2i const& d) const { return delta2i(dx - d.dx, dy - d.dy); }
	delta2i operator-() const { return delta2i(-dx, -dy); }

	bool operator==(const delta2i& d) const { return dx == d.dx && dy == d.dy; }
	bool operator!=(const delta2i& d) const { return !(*this == d); }

	void operator+=(const delta2i& d) { dx += d.dx; dy += d.dy; }
	
	int area(void) const { return dx * dy; }
	
	void assign(const delta2i& d) { dx = d.dx; dy = d.dy; }
	void assign(int dx, int dy) { this->dx = dx; this->dy = dy; }
	
	bool empty() const { return dx <= 0 || dy <= 0; }
	delta2i add_quarter_rotation() const { return delta2i(-dy, dx); }
	delta2i subtract_quarter_rotation() const { return delta2i(dy, -dx); }
	delta2i half_rotation() const { return delta2i(-dx, -dy); }
	delta2i negate() const { return delta2i(-dx, -dy); }

	std::string to_string() const;

	static delta2i const& zero();
};

}

#endif // ARCIEM_DELTA2I_HPP