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

#ifndef ARCIEM_AREA_HPP
#define ARCIEM_AREA_HPP

#include "point2.hpp"
#include "delta2.hpp"
#include "align.hpp"

#include <string>

namespace arciem {

class area {
public:
	point2 origin;
	delta2 size;
	
	area() { }
	area(point2 const& origin, delta2 const& size) : origin(origin), size(size) { }
	area(point2 const& corner1, point2 const& corner2);
	explicit area(point2 const& origin) : origin(origin) { }
	explicit area(delta2 const& size) : size(size) { }
	area(double x, double y, double dx, double dy) : origin(x, y), size(dx, dy) { }
	area(double x_min, double y_min, double x_max, double y_max, int) : origin(x_min, y_min), size(x_max - x_min, y_max - y_min) { }
//	area(area const& a) : origin(a.origin), size(a.size) { }
	
	double x_min() const { return origin.x; }
	double y_min() const { return origin.y; }
	double x_max() const { return origin.x + size.dx; }
	double y_max() const { return origin.y + size.dy; }
	
	point2 x_min_y_min() const { return origin; }
	point2 x_min_y_max() const { return point2(x_min(), y_max()); }
	point2 x_max_y_min() const { return point2(x_max(), y_min()); }
	point2 x_max_y_max() const { return point2(x_max(), y_max()); }
	
	double x_center() const { return origin.x + size.dx / 2.0; }
	double y_center() const { return origin.y + size.dy / 2.0; }
	point2 center() const { return point2(x_center(), y_center()); }
	
	bool empty() const { return size.empty(); }
	bool contains(point2 const& p) const { return p.x >= x_min() && p.x <= x_max() && p.y >= y_min() && p.y <= y_max(); }
	bool contains(area const& a) const;
	bool overlap(area const& a) const;
	
	area normalize() const;
	area set_x_center(double x) const;
	area set_y_center(double y) const;
	area set_x_min(double n, bool flexible = false) const;
	area set_y_min(double n, bool flexible = false) const;
	area set_x_max(double n, bool flexible = false) const;
	area set_y_max(double n, bool flexible = false) const;
	area set_dx(double n, bool flexible_max) const;
	area set_dy(double n, bool flexible_max) const;
	area set_origin(point2 const& o, bool flexible_max) const;
	area offset(delta2 const& d) const { return area(origin + d, size); }
	area offset_x(double dx) const { return area(point2(origin.x + dx, origin.y), size); }
	area offset_y(double dy) const { return area(point2(origin.x, origin.y + dy), size); }
	area offset_x_min(double n) const { return set_x_min(x_min() + n, true); }
	area offset_y_min(double n) const { return set_y_min(y_min() + n, true); }
	area offset_x_max(double n) const { return set_x_max(x_max() + n, true); }
	area offset_y_max(double n) const { return set_y_max(y_max() + n, true); }
	area set_origin(point2 const& o) const { return area(o, size); }
	area set_size(delta2 const& s) const { return area(origin, s); }
	area set_dx(double n) const { return area(origin, delta2(n, size.dy)); }
	area set_dy(double n) const { return area(origin, delta2(size.dx, n)); }
	area set_center(point2 const& p) const;
	static double inset(double min, double size, double inset);
	area inset(double x_inset, double y_inset) const;
	area inset(delta2 const& d) const { return inset(d.dx, d.dy); }
	area inset(double n) const { return inset(n, n); }
	area union_with_empty(area const& a) const;
	area union_no_empty(area const& a) const;
	area union_no_empty(point2 const& p) const;
	area integral() const;
	area interpolate(area const& a, double fraction) const;
	area flip_relative_to(area const& a) const;
	area align_to(point2 const& p, align_t align) const;
	area align_to(area const& a, align_t align) const;
	
	area operator+(delta2 const& d) const { return area(origin + d, size); }
	void operator+=(delta2 const& d) { origin += d; }

	inline void operator/=(delta2 const& d) { origin /= d; size /= d; }

	inline bool operator==(const area& a) const { return origin == a.origin && size == a.size; }
	inline bool operator!=(const area& a) const { return !(*this == a); }

	std::string to_string() const;
	
	void get(double& x, double& y, double& dx, double& dy) const { x = origin.x; y = origin.y; dx = size.dx; dy = size.dy; }
	void get(double& x_min, double& y_min, double& x_max, double& y_max, int) const { x_min = origin.x; y_min = origin.y; x_max = origin.x + size.dx; y_max = origin.y + size.dy; }
	
	static area const& zero();
};

} // namespace

#endif // ARCIEM_AREA_HPP
