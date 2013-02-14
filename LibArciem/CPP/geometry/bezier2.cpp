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

#include "bezier2.hpp"
#include "stringstreams.hpp"

#include <float.h>
#include <iostream>

using namespace std;

namespace arciem {

bezier2 const& bezier2::zero() { static bezier2* b = new bezier2(); return *b; }

point2 bezier2::point(double fraction) const
{
	// The "de Casteljau algorithm" as simplified by Mathematica

	double tm = fraction - 1.0;
	double tmc = tm * tm * tm;
	double tc = fraction * fraction * fraction;
	double tmf3 = 3.0 * tm * fraction;
	
	return point2(
		-(tmc * x1()) + tmf3 * (tm * x2() - fraction * x3()) + tc * x4(),
		-(tmc * y1()) + tmf3 * (tm * y2() - fraction * y3()) + tc * y4()
	);
}

delta2 bezier2::speed(double fraction) const
{
	// The first derivative of point(fraction)
	
	double ts = fraction * fraction;
	double t2 = 2 * fraction;
	
	return delta2(
		3.0 * (-x1() + x2() + t2 * (x1() - 2 * x2() + x3()) + ts * (-x1() + 3 * x2() - 3 * x3() + x4())),
		3.0 * (-y1() + y2() + t2 * (y1() - 2 * y2() + y3()) + ts * (-y1() + 3 * y2() - 3 * y3() + y4()))
	);
}

delta2 bezier2::direction(double fraction, delta2 const& speed_zero_direction) const
{
	delta2 sp = speed(fraction);
	if(sp == delta2::zero()) {
		return speed_zero_direction;
	} else {
		return sp.normalize();
	}
}

bezier2 bezier2::interpolate(bezier2 const& b, double fraction) const
{
	return bezier2(
		denormalize(fraction, x1(), b.x1()),
		denormalize(fraction, y1(), b.y1()),
		denormalize(fraction, x2(), b.x2()),
		denormalize(fraction, y2(), b.y2()),
		denormalize(fraction, x3(), b.x3()),
		denormalize(fraction, y3(), b.y3()),
		denormalize(fraction, x4(), b.x4()),
		denormalize(fraction, y4(), b.y4())
	);
}

double bezier2::distance_to_point(point2 const& p, unsigned samples) const
{
	double td = 1.0 / samples;
	point2 last = p1;
	double distance = DBL_MAX;
	for(unsigned i = 1; i <= samples; ++i) {
		double t = td * i;
		point2 cur = point(t);
		double d = line2(last, cur).distance_from_segment_to_point(p);
		if(d < distance) distance = d;
		last = cur;
	}
	return distance;
}

void bezier2::operator+=(const delta2& d) {
	p1 += d; p2 += d; p3 += d; p4 += d;
}

area bezier2::frame() const
{
	return area(p1, p4).union_no_empty(area(p2, p3));
}

string bezier2::to_string() const
{
	outputstringstream o;
	
	o << "[p1:" << p1.to_string() << " p2:" << p2.to_string() << " p3:" << p3.to_string() << " p4:" << p4.to_string() << "]";
	
	return o.extract();
}

point2_list bezier2::outline(double line_width, double t_begin, double t_end, unsigned segments) const
{
	double halfLineWidth = line_width / 2.0;
	
	point2_list points;
	
	if(!is_point()) {
		point2_list back_points;

		double t_per_segment = (t_end - t_begin) / segments;
		for(unsigned i = 0; i <= segments; ++i) {
			double t = t_begin + i * t_per_segment;
			point2 t_point = point(t);
			delta2 sp = speed(t);		// speed can be zero when several control points coincide
			if(sp != delta2::zero()) {
				delta2 dir = sp.normalize();
				delta2 offset = dir.add_quarter_rotation() * halfLineWidth;
				point2 front_point = t_point + offset;
				point2 back_point = t_point - offset;
				points.push_back(front_point);
				back_points.push_front(back_point);
			}
		}
		
		points.insert(points.end(), back_points.begin(), back_points.end());
	}

#if 0	
	unsigned s = points.size();
	for(unsigned i = 0; i < s; ++i) {
		point2 const& p = points[i];
		if(__isnand(p.x) || __isnand(p.y)) {
			cout << "############# WARNING: GENERATED NAN. Bezier: " << to_string() << " points: " << points.to_string() << endl;
		}
	}
#endif
	
	return points;
}

} // namespace

