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

#include <arciem/geometry/wedge2.hpp>

namespace arciem {

double wedge2::optical_mid_radius() const
{
	double n;
	if(is_sector())
		n = 0.6;
	else
		n = 0.5;

//	double thickness = outer_radius() - inner_radius();
//	double g = inner_radius() / thickness;
//	double h = inner_radius() / outer_radius();
//	double i = g * h;
//	double n = denormalize(g, 0.7, 0.5);
	return denormalize(n, inner_radius(), outer_radius());
}

#if 0
area wedge2::frame(int) const
{
	return area(inner_start()).union_no_empty(outer_start()).union_no_empty(inner_end()).union_no_empty(outer_end());
}
#endif

bool wedge2::contains(double angle, double radius) const
{
	double endAngle = end_angle();
	if(angle >= mStartAngle && angle <= endAngle && radius >= mInnerRadius && radius <= mRadius)
		return true;
	else {
		angle += two_pi;
		return angle >= mStartAngle && angle <= endAngle && radius >= mInnerRadius && radius <= mRadius;
	}
}

bool wedge2::contains(point2 const& p) const
{
	delta2 dp = p - mCenter;
	double angle = normalize_angle(dp.angle());
	double radius = dp.distance();
	return contains(angle, radius);
}

} // namespace arciem
