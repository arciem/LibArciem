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

#include <arciem/geometry/arc2.hpp>
#include <cmath>

namespace arciem {

void arc2::set_center_angle(double centerAngle)
{
	mStartAngle = normalize_angle(centerAngle - mSweepAngle / 2.0);
}

double arc2::parameter(delta2 const& d) const
{
	double fi;

	// Calculate angle fi, given by d.
	if(d.dx == 0.0) {
		if(d.dy >= 0.0) {
			fi = M_PI_2;
		} else {
			if(mStartAngle >= 0.0) {
				fi = 3.0 * M_PI_2;
			} else {
				fi = -M_PI_2;
			}
		}
	} else {
		fi = atan(d.dy / d.dx);
		if(d.dx < 0.0) {
			fi += pi;
		}
		
		if(fi < 0.0 && mStartAngle >= 0.0) {
			fi += two_pi;
		}
	}

	// Normalize fi.
	if(fi + two_pi < mStartAngle + mSweepAngle) fi += two_pi;
	if(fi - two_pi > mStartAngle ) fi -= two_pi;

	// Calculate corresponding u-value.
	double u = 1.0 + (fi - mStartAngle) / mSweepAngle;
	
	return u;
}

unsigned arc2::intersects_with_line(line2 const& l, point2& ip1, point2& ip2, bool line_segment) const
{
	unsigned solutionCount = 0;

	double const TOL2 = 0.001;
	double const TOL4 = 0.0001;

	// Vertical, horizontal or sloping line?

	// Horizontal
	double x1, y1, x2, y2;
	double lineParams[2];
	double dx = l.p2.x - l.p1.x;
	double dy = l.p2.y - l.p1.y;
	if( fabs(dx) > 1000.0 * fabs(dy) ) {
		if( fabs(l.p1.y - mCenter.y) - mRadius > TOL2 ) {
			return solutionCount;
		}

		y1 = y2 = l.p1.y;

		if( mRadius > fabs(l.p1.y - mCenter.y) ) {
			x1 = mCenter.x + mRadius * cos(asin((l.p1.y - mCenter.y) / mRadius));
			x2 = 2.0 * mCenter.x - x1;
		} else {
			x1 = x2 = mCenter.x;
		}

		// Compute line parametric values.
		lineParams[0] = 1.0 + (x1 - l.p1.x) / dx;
		lineParams[1] = 1.0 + (x2 - l.p1.x) / dx;

	// Vertical
	} else if( fabs(dy) > 1000.0 * fabs(dx) ) {
		if( fabs(l.p1.x - mCenter.x) - mRadius > TOL2 ) {
			return solutionCount;
		}

		x1 = x2 = l.p1.x;

		if( mRadius > fabs(l.p1.x - mCenter.x) ) {
			y1 = mCenter.y + mRadius * sin(acos((l.p1.x - mCenter.x) / mRadius));
			y2 = 2.0 * mCenter.y - y1;
		} else {
			y1 = y2 = mCenter.y;
		}

		// Compute line parametric values.
		lineParams[0] = 1.0 + (y1 - l.p1.y) / dy;
		lineParams[1] = 1.0 + (y2 - l.p1.y) / dy;
	
	// Sloping
	} else {
		double k = dy / dx;
		double k2 = k * k;

		double p = (
			mCenter.x
			+ k2 * l.p1.x
			- k * (l.p1.y - mCenter.y)
		) / (1.0 + k2);

		double q = (
			mCenter.x * mCenter.x
			+ k2 * l.p1.x * l.p1.x
			+ 2.0 * k * l.p1.x * (mCenter.y - l.p1.y)
			+ (l.p1.y - mCenter.y) * (l.p1.y - mCenter.y)
			- mRadius * mRadius
		) / (1.0 + k2);

		// Do they intersect?
		double tt;
		if( (tt = p * p - q) < 0.0 && tt > -TOL2 ) {
			tt = 0.0;
		}

		if(tt >= 0.0) {
			// Yes, analytical solution.
			x1 = p + sqrt(tt);
			y1 = k * (x1 - l.p1.x) + l.p1.y;
			x2 = p - sqrt(tt);     
			y2 = k * (x2 - l.p1.x) + l.p1.y;
		
		// No intersect.
        } else {
			return solutionCount;
        }

		// Compute line parametric values.
		lineParams[0] = 1.0 + (x1 - l.p1.x) / dx;
		lineParams[1] = 1.0 + (x2 - l.p1.x) / dx;
	}
	
	// Compute arc parametric values.
	dx = x1 - mCenter.x;
	dy = y1 - mCenter.y;
	double arcParams[2];
	arcParams[0] = parameter(delta2(dx, dy));

	dx = x2 - mCenter.x;
	dy = y2 - mCenter.y;
	arcParams[1] = parameter(delta2(dx, dy));

	// if the line is a segment, then remove intersects outside its actual length
	solutionCount = 2;
	point2 s1(x1, y1);
	point2 s2(x2, y2);
	if(line_segment) {
		if(lineParams[0] < 1.0 - TOL4 || lineParams[0] > 2.0 + TOL4 || arcParams[0] < 1.0 - TOL4 || arcParams[0] > 2.0 + TOL4) {
			lineParams[0] = lineParams[1];
			arcParams[0] = arcParams[1];
			s1 = s2;
			solutionCount = 1;
		}

		if(lineParams[1] < 1.0 - TOL4 || lineParams[1] > 2.0 + TOL4 || arcParams[1] < 1.0 - TOL4 || arcParams[1] > 2.0 + TOL4) {
			solutionCount -= 1;
		}
	}
	
	if(solutionCount > 0) {
		ip1 = s1;
		if(solutionCount > 1) {
			ip2 = s2;
		}
	}

	return solutionCount;
}

bool arc2::includes(double angle) const
{
	double endAngle = mStartAngle + mSweepAngle;
	
	if(mStartAngle <= angle && angle <= endAngle) return true;
	angle += two_pi;
	if(mStartAngle <= angle && angle <= endAngle) return true;
	return false;
}

area arc2::frame() const
{
	area a = area(mCenter).union_no_empty(start()).union_no_empty(end());
	
	delta2 start = delta2::from_polar(mRadius, start_angle());
	delta2 end = delta2::from_polar(mRadius, end_angle());
	
	if(includes(0.0)) {
		a = a.union_no_empty(mCenter + delta2(mRadius, 0.0));
	}
	
	if(includes(M_PI_2)) {
		a = a.union_no_empty(mCenter + delta2(0.0, mRadius));
	}
	
	if(includes(pi)) {
		a = a.union_no_empty(mCenter + delta2(-mRadius, 0.0));
	}
	
	if(includes(pi + M_PI_2)) {
		a = a.union_no_empty(mCenter + delta2(0.0, -mRadius));
	}
	
	return a;
}

double arc2::mid_angle() const
{
	double a = mStartAngle + mSweepAngle / 2.0;
	if(a > two_pi) a -= two_pi;
	return a;
}

} // namespace arciem