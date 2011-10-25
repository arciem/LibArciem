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

#ifndef ARCIEM_BEZIER2_HPP
#define ARCIEM_BEZIER2_HPP

#include <string>
#include <vector>

#include <arciem/geometry/line2.hpp>
#include <arciem/geometry/point2_list.hpp>

namespace arciem {

class bezier2 {
public:
	point2 p1;
	point2 p2;
	point2 p3;
	point2 p4;

	bezier2() { }
	bezier2(const point2& p1, const point2& p2, const point2& p3, const point2& p4) : p1(p1), p2(p2), p3(p3), p4(p4) { }
	bezier2(const point2& p) : p1(p), p2(p), p3(p), p4(p) { }
	bezier2(const line2& l) : p1(l.p1), p2(l.point(1.0/3.0)), p3(l.point(2.0/3.0)), p4(l.p2) { }
	bezier2(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) : p1(x1, y1), p2(x2, y2), p3(x3, y3), p4(x4, y4) { }
	bezier2(const bezier2& b) : p1(b.p1), p2(b.p2), p3(b.p3), p4(b.p4) { }
	double x1() const { return p1.x; }
	double y1() const { return p1.y; }
	double x2() const { return p2.x; }
	double y2() const { return p2.y; }
	double x3() const { return p3.x; }
	double y3() const { return p3.y; }
	double x4() const { return p4.x; }
	double y4() const { return p4.y; }
	
	bool empty() const { return p1 == p2 && p2 == p3 && p3 == p4; }

	bezier2 operator+(delta2 const& d) const { return bezier2(p1 + d, p2 + d, p3 + d, p4 + d); }
	void operator+=(const delta2& d);

	bool operator==(const bezier2& b) const { return p1 == b.p1 && p2 == b.p2 && p3 == b.p3 && p4 == b.p4; }
	bool operator!=(const bezier2& b) const { return !(*this == b); }

	area frame() const;
	point2 point(double fraction) const;
	delta2 speed(double fraction) const;
	delta2 direction(double fraction, delta2 const& speed_zero_direction = delta2(1.0, 0.0)) const;
	bezier2 interpolate(bezier2 const& b, double fraction) const;
	double distance_to_point(point2 const& point, unsigned samples = 30) const;
	bool is_point() const { return p1 == p2 && p1 == p3 && p1 == p4; }
	bezier2 reverse() const { return bezier2(p4, p3, p2, p1); }

	point2_list outline(double line_width, double t_begin = 0.0, double t_end = 1.0, unsigned segments = 20) const;

	std::string to_string() const;
	
	static bezier2 const& zero();
};

} // namespace

#endif // ARCIEM_BEZIER2_HPP