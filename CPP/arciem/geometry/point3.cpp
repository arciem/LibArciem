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
#include <arciem/geometry/point3.hpp>
#include <arciem/geometry/volume.hpp>
#include <arciem/stringstreams.hpp>

namespace arciem {

point3 const& point3::zero() { static point3* p = new point3(); return *p; }

point3::point3(point2 const& p) : x(p.x), y(p.y), z(0.0) { }

point3 point3::clamp_inside(volume const& v) const
{
	return point3(
		clamp(x, v.x_min(), v.x_max()),
		clamp(y, v.y_min(), v.y_max()),
		clamp(z, v.z_min(), v.z_max())
	);
}

std::string point3::to_string() const
{
	outputstringstream o;
	
	o << "[x:" << x << " y:" << y  << " z:" << z << "]";
	
	return o.extract();
}

}