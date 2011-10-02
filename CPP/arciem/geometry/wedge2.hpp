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

#ifndef ARCIEM_WEDGE2_HPP
#define ARCIEM_WEDGE2_HPP

#include <arciem/geometry/arc2.hpp>

namespace arciem {

class wedge2 : public arc2 {
public:
	wedge2() : mInnerRadius(0.0) { }
	wedge2(point2 const& center, double startAngle = 0.0, double sweepAngle = 0.0, double outerRadius = 0.0, double innerRadius = 0.0)
		: arc2(center, startAngle, sweepAngle, outerRadius)
		, mInnerRadius(innerRadius)
	{ }
	
	double outer_radius() const { return mRadius; }
	double inner_radius() const { return mInnerRadius; }
	
	void set_outer_radius(double outerRadius) { set_radius(outerRadius); }
	void set_inner_radius(double innerRadius) { mInnerRadius = innerRadius; }

	point2 inner_start() const { return mCenter + delta2::from_polar(mInnerRadius, start_angle()); }
	point2 outer_start() const { return start(); }
	point2 inner_end() const { return mCenter + delta2::from_polar(mInnerRadius, end_angle()); }
	point2 outer_end() const { return end(); }
	
	line2 start_line() const { return line2(inner_start(), outer_start()); }
	line2 end_line() const { return line2(inner_end(), outer_end()); }
	
	arc2 const& outer() const { return *this; }
	arc2 inner() const { return arc2(mCenter, mStartAngle, mSweepAngle, mInnerRadius); }

	double mid_radius() const { return denormalize(0.5, inner_radius(), outer_radius()); }
	point2 mid() const { return mCenter + delta2::from_polar(mid_radius(), mid_angle()); }
	double optical_mid_radius() const;
	point2 optical_mid() const { return mCenter + delta2::from_polar(optical_mid_radius(), mid_angle()); }
//	area frame(int) const;
	bool contains(point2 const& p) const;
	bool contains(double angle, double radius) const;
	
	bool is_sector() const { return mInnerRadius < 0.0001; }

	bool start_intersects_with_line(line2 const &l, point2& ip, bool line_segments = true) const
		{ return start_line().intersects_with_line(l, ip, line_segments); }
	bool end_intersects_with_line(line2 const &l, point2& ip, bool line_segments = true) const
		{ return end_line().intersects_with_line(l, ip, line_segments); }
	unsigned outer_intersects_with_line(line2 const& l, point2& ip1, point2& ip2, bool line_segment = true) const
		{ return outer().intersects_with_line(l, ip1, ip2, line_segment); }
	unsigned inner_intersects_with_line(line2 const& l, point2& ip1, point2& ip2, bool line_segment = true) const
		{ return inner().intersects_with_line(l, ip1, ip2, line_segment); }

private:
	double mInnerRadius;
};

} // namespace arciem

#endif // ARCIEM_WEDGE2_HPP