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

#include "point2i.hpp"

#include "areai.hpp"

#include "stringstreams.hpp"

namespace arciem {

point2i const& point2i::zero() { static point2i* p = new point2i(); return *p; }

std::string point2i::to_string() const
{
	outputstringstream o;
	
	o << "[x:" << x << " y:" << y << "]";
	
	return o.extract();
}

point2i point2i::flip_relative_to(areai const& a) const
{
	return point2i(x, a.size.dy - y + 2 * a.origin.y);
}

}