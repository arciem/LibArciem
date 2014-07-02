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

#ifndef ARCIEM_AREAI_H
#define ARCIEM_AREAI_H

#include "point2i.hpp"
#include "delta2i.hpp"
#include "align.hpp"

#include <string>

class areai {
public:
	point2i origin;
	delta2i size;
	
	areai() { }
	areai(point2i const& origin, delta2i const& size) : origin(origin), size(size) { }
	areai(point2i const& corner1, point2i const& corner2);
	areai(delta2i const& size) : size(size) { }
	areai(int x, int y, int dx, int dy) : origin(x, y), size(dx, dy) { }
	areai(int x_min, int y_min, int x_max, int y_max, int) : origin(x_min, y_min), size(x_max - x_min + 1, y_max - y_min + 1) { }
//	areai(areai const& a) : origin(a.origin), size(a.size) { }
	
	int x_min() const { return origin.x; }
	int y_min() const { return origin.y; }
	int x_max() const { return origin.x + size.dx - 1; }
	int y_max() const { return origin.y + size.dy - 1; }
	
	point2i x_min_y_min() const { return origin; }
	point2i x_min_y_max() const { return point2i(x_min(), y_max()); }
	point2i x_max_y_min() const { return point2i(x_max(), y_min()); }
	point2i x_max_y_max() const { return point2i(x_max(), y_max()); }
	
	int x_center() const { return origin.x + size.dx / 2; }
	int y_center() const { return origin.y + size.dy / 2; }
	point2i center() const { return point2i(x_center(), y_center()); }
	
	bool empty() const { return size.empty(); }
	bool contains(point2i const& p) const { return p.x >= x_min() && p.x <= x_max() && p.y >= y_min() && p.y <= y_max(); }
	bool contains(areai const& a) const;
	bool overlap(areai const& a) const;
	
	areai normalize() const;
	areai set_x_center(int x) const;
	areai set_y_center(int y) const;
	areai set_x_min(int n, bool flexible = false) const;
	areai set_y_min(int n, bool flexible = false) const;
	areai set_x_max(int n, bool flexible = false) const;
	areai set_y_max(int n, bool flexible = false) const;
	areai set_dx(int n, bool flexible_max) const;
	areai set_dy(int n, bool flexible_max) const;
	areai set_origin(point2i const& o, bool flexible_max) const;
	areai offset(delta2i const& d) const { return areai(origin + d, size); }
	areai offset_x(int dx) const { return areai(point2i(origin.x + dx, origin.y), size); }
	areai offset_y(int dy) const { return areai(point2i(origin.x, origin.y + dy), size); }
	areai offset_x_min(int n) const { return set_x_min(x_min() + n, true); }
	areai offset_y_min(int n) const { return set_y_min(y_min() + n, true); }
	areai offset_x_max(int n) const { return set_x_max(x_max() + n, true); }
	areai offset_y_max(int n) const { return set_y_max(y_max() + n, true); }
	areai set_origin(point2i const& o) const { return areai(o, size); }
	areai set_size(delta2i const& s) const { return areai(origin, s); }
	areai set_dx(int n) const { return areai(origin, delta2i(n, size.dy)); }
	areai set_dy(int n) const { return areai(origin, delta2i(size.dx, n)); }
	areai set_center(point2i const& p) const;
	static int inset(int min, int size, int inset);
	areai inset(int x_inset, int y_inset) const;
	areai inset(delta2i const& d) const { return inset(d.dx, d.dy); }
	areai inset(int n) const { return inset(n, n); }
	areai union_with_empty(areai const& a) const;
	areai union_no_empty(areai const& a) const;
	areai flip_relative_to(areai const& a) const;
	areai align_to(point2i const& p, align_t align) const;
	areai align_to(areai const& a, align_t align) const;
	
	areai operator+(delta2i const& d) const { return areai(origin + d, size); }
	void operator+=(delta2i const& d) { origin += d; }

	bool operator==(const areai& a) const { return origin == a.origin && size == a.size; }
	bool operator!=(const areai& a) const { return !(*this == a); }

	string to_string() const;
	
	void get(int& x, int& y, int& dx, int& dy) const { x = origin.x; y = origin.y; dx = size.dx; dy = size.dy; }
	void get(int& x_min, int& y_min, int& x_max, int& y_max, int) const { x_min = origin.x; y_min = origin.y; x_max = origin.x + size.dx; y_max = origin.y + size.dy; }
	
	static areai const& zero();
};

#endif // ARCIEM_AREAI_H