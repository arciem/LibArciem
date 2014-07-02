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

#ifndef ARCIEM_POINT2I_H
#define ARCIEM_POINT2I_H

#include "delta2i.hpp"

#include <string>

namespace arciem {

class areai;

class point2i {
public:
	int x, y;
	
	point2i(int x = 0, int y = 0) : x(x), y(y) { }

	point2i operator+(int n) const { return point2i(x + n, y + n); }
	point2i operator-(int n) const { return point2i(x - n, y - n); }
	point2i operator+(delta2i const& d) const { return point2i(x + d.dx, y + d.dy); }
	point2i operator-(delta2i const& d) const { return point2i(x - d.dx, y - d.dy); }
	delta2i operator-(point2i const& p) const { return delta2i(x - p.x, y - p.y); }
	point2i operator-() const { return point2i(-x, -y); }

	bool operator==(const point2i& p) const { return x == p.x && y == p.y; }
	bool operator!=(const point2i& p) const { return !(*this == p); }

	void operator+=(const delta2i& d) { x += d.dx; y += d.dy; }

	void assign(int x, int y) { this->x = x; this->y = y; }

	point2i flip_relative_to(areai const& a) const;
	
	string to_string() const;

	static point2i const& zero();
};

}

#endif // ARCIEM_POINT2I_H