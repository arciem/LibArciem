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

#ifndef ARCIEM_ORIENTATION_HPP
#define ARCIEM_ORIENTATION_HPP

#include "geometry.hpp"
#include "delta3.hpp"

namespace arciem {

class orientation
{
public:
	delta3 axis;
	angle_t angle;
	
	orientation() : axis(-delta3::z_axis()), angle(0.0) { }
	orientation(const delta3& axis, angle_t angle) : axis(axis), angle(angle) { }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfloat-equal"
	bool operator==(orientation const& o) const { return axis == o.axis && angle == o.angle; }
#pragma clang diagnostic pop
	bool operator!=(orientation const& o) const { return !(*this == o); }
};

} // namespace arciem

#endif // ARCIEM_ORIENTATION_HPP