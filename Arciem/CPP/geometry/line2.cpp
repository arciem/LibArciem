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

#include "line2.hpp"

#include "stringstreams.hpp"
#include "math_utils.hpp"

namespace arciem {

line2 const& line2::zero() { static line2* l = new line2(); return *l; }

double line2::distance_from_line_to_point(point2 const& point) const
{
	delta2 v = p2 - p1;
	delta2 w = point - p1;
	
	double c1 = w.dot(v);
	double c2 = v.dot(v);
	double b = c1 / c2;
	
	point2 Pb = p1 + v * b;
	return point.distance(Pb);
}

double line2::distance_from_segment_to_point(point2 const& point) const
{
	delta2 v = p2 - p1;
	delta2 w = point - p1;
	
	double c1 = w.dot(v);
	if(c1 <= 0)
		return point.distance(p1);
	
	double c2 = v.dot(v);
	if(c2 <= c1)
		return point.distance(p2);
	
	double b = c1 / c2;
	point2 Pb = p1 + v * b;
	return point.distance(Pb);
}

line2 line2::interpolate(line2 const& l, double fraction) const
{
	return line2(
		denormalize(fraction, x1(), l.x1()),
		denormalize(fraction, y1(), l.y1()),
		denormalize(fraction, x2(), l.x2()),
		denormalize(fraction, y2(), l.y2())
	);
}

std::string line2::to_string() const
{
	outputstringstream o;
	
	o << "[p1:" << p1.to_string() << " p2:" << p2.to_string() << "]";
	
	return o.extract();
}

bool line2::intersects_with_line(line2 const &l, point2& ip, bool line_segments) const
{
	double x1 = p1.x;
	double y1 = p1.y;
	double x2 = p2.x;
	double y2 = p2.y;
	double x3 = l.p1.x;
	double y3 = l.p1.y;
	double x4 = l.p2.x;
	double y4 = l.p2.y;
	
	double const TOL = 0.0001;
	
    double q1 = (x1 - x2) * (y4 - y3) - (y1 - y2) * (x4 - x3);
    double q2 = (x3 - x4) * (y2 - y1) - (y3 - y4) * (x2 - x1);
	
	// Are the lines parallel?
	if(fabs(q1) < TOL) return false;
	
	// Compute the intersection parameters
	double u1 = ((x1 - x3) * (y4 - y3) - (y1 - y3) * (x4 - x3)) / q1;
	double u2 = ((x3 - x1) * (y2 - y1) - (y3 - y1) * (x2 - x1)) / q2;

	// Do the lines need to intersect within their finite length?
	if(line_segments) {
		if(u1 < -TOL || u1 > 1.0 + TOL || u2 < -TOL || u2 > 1.0 + TOL) return false;
	}
	
	ip.x = denormalize(u1, p1.x, p2.x);
	ip.y = denormalize(u1, p1.y, p2.y);
	
	return true;
}

}