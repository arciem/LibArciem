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

#ifndef ARCIEM_ARC2_HPP
#define ARCIEM_ARC2_HPP

#include "line2.hpp"

namespace arciem {

class arc2 {
public:	
	arc2() : mStartAngle(0.0), mSweepAngle(0.0), mRadius(0.0) { }
	arc2(point2 const& center, double startAngle = 0.0, double sweepAngle = 0.0, double radius = 0.0)
		: mCenter(center)
		, mStartAngle(startAngle)
		, mSweepAngle(sweepAngle)
		, mRadius(radius)
	{ }
	
	double start_angle() const { return mStartAngle; }
	double sweep_angle() const { return mSweepAngle; }
	double end_angle() const { return mStartAngle + mSweepAngle; }
	double radius() const { return mRadius; }
	
	double mid_angle() const;
	
	void set_center(point2 const& center) { mCenter = center; }
	void set_radius(double radius) { mRadius = radius; }
	void set_start_angle(double startAngle) { mStartAngle = startAngle; }
	void set_sweep_angle(double sweepAngle) { mSweepAngle = sweepAngle; }
	void set_center_angle(double centerAngle);
	
	bool is_circle() const { return fabs(mSweepAngle - two_pi) < 0.0001; }
	
	point2 const& center() const { return mCenter; }
	point2 start() const { return mCenter + delta2::from_polar(mRadius, start_angle()); }
	point2 end() const { return mCenter + delta2::from_polar(mRadius, end_angle()); }
	bool includes(double angle) const;
	area frame() const;
	
	double parameter(delta2 const& d) const;
	unsigned intersects_with_line(line2 const& l, point2& ip1, point2& ip2, bool line_segment = true) const;

protected:
	point2 mCenter;
	double mStartAngle;
	double mSweepAngle;
	double mRadius;
};

} // namespace arciem

#endif // ARCIEM_ARC2_HPP
