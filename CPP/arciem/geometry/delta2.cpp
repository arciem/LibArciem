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

#include <arciem/geometry/delta2.hpp>

#include <arciem/stringstreams.hpp>

namespace arciem {

delta2 const& delta2::zero() { static delta2* d = new delta2(); return *d; }

std::string delta2::to_string() const
{
	outputstringstream o;
	
	o << "[dx:" << dx << " dy:" << dy << "]";
	
	return o.extract();
}

delta2 delta2::rotate(double angle) const
{
	double ca = cos(angle);
	double sa = sin(angle);
	
	return delta2(
		dx * ca - dy * sa,
		dy * ca + dx * sa
	);
}

delta2 delta2::integral() const
{
	if(empty()) {
		return zero();
	} else {
		return delta2(ceil(dx), ceil(dy));
	}
}

delta2 delta2::from_polar(double r, double theta)
{
	return delta2(r * cos(theta), r * sin(theta));
}

}