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

#include <arciem/geometry/point2.hpp>
#include <arciem/geometry/point2i.hpp>

#include <arciem/stringstreams.hpp>

#include <arciem/geometry/area.hpp>
#include <arciem/essentials/math_utils.hpp>

namespace arciem {

point2 const& point2::zero() { static point2* p = new point2(); return *p; }

point2::point2(point2i const& p) : x(p.x), y(p.y) { }

std::string point2::to_string() const
{
	outputstringstream o;
	
	o << "[x:" << x << " y:" << y << "]";
	
	return o.extract();
}

point2 point2::flip_relative_to(area const& a) const
{
	return point2(x, a.size.dy - y + 2 * a.origin.y);
}

point2 point2::clamp_inside(area const& a) const
{
	return point2(
		clamp(x, a.x_min(), a.x_max()),
		clamp(y, a.y_min(), a.y_max())
	);
}

point2 point2::rotate_relative_to(double angle, point2 const& p) const
{
	double ox = p.x;
	double oy = p.y;
	
	double v1 = sin(angle);
	double v2 = cos(angle);
	double v3 = -oy + y;
	double v4 = -ox + x;
	return point2(ox - v1*v3 + v2*v4, oy + v2*v3 + v1*v4);
}

} // namespace arciem