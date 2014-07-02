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

#ifndef ARCIEM_LINE2_H
#define ARCIEM_LINE2_H

#include "delta2.hpp"
#include "point2.hpp"
#include "area.hpp"
#include "geometry.h"

#include <string>

namespace arciem {

class line2 {
public:
	point2 p1;
	point2 p2;
	
	line2() { }
	line2(const point2& p1, const point2& p2) : p1(p1), p2(p2) { }
	line2(double x1, double y1, double x2, double y2) : p1(x1, y1), p2(x2, y2) { }
	line2(const line2& l) : p1(l.p1), p2(l.p2) { }
	double x1() const { return p1.x; }
	double y1() const { return p1.y; }
	double x2() const { return p2.x; }
	double y2() const { return p2.y; }
	
	void assign(double x1, double y1, double x2, double y2)
	{
		p1.assign(x1, y1);
		p2.assign(x2, y2);
	}
	
	double dx() const { return p2.x - p1.x; }
	double dy() const { return p2.y - p1.y; }
	double slope() const { return dy() / dx(); }
	double distance() const { return distance2(dx(), dy()); }
	double distance_squared() const { return distance_squared2(dx(), dy()); }
	double angle() const { return angle2(dx(), dy()); }
	area frame() const { return area(p1, p2); }
	point2 point(double fraction) const { return point2((p1.x + p2.x) * fraction, (p1.y + p2.y) * fraction); }
	point2 midpoint() const { return point(0.5); }
	line2 interpolate(line2 const& l, double fraction) const;
	double distance_from_line_to_point(point2 const& point) const;
	double distance_from_segment_to_point(point2 const& point) const;
	bool intersects_with_line(line2 const &l, point2& ip, bool line_segments = true) const;
	
	static line2 x_min(area const& a) { return line2(a.x_min_y_min(), a.x_min_y_max()); }
	static line2 x_max(area const& a) { return line2(a.x_max_y_min(), a.x_max_y_max()); }
	static line2 y_min(area const& a) { return line2(a.x_min_y_min(), a.x_max_y_min()); }
	static line2 y_max(area const& a) { return line2(a.x_min_y_max(), a.x_max_y_max()); }

	line2 operator+(const delta2& d) const { return line2(p1 + d, p2 + d); }
	void operator+=(const delta2& d) { p1 += d; p2 += d; }

	bool operator==(const line2& l) const { return p1 == l.p1 && p2 == l.p2; }
	bool operator!=(const line2& l) const { return !(*this == l); }

	string to_string() const;
	
	static line2 const& zero();
};

}

#endif // ARCIEM_LINE2_H