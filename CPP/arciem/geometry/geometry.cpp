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

#include <arciem/geometry/geometry.hpp>

using namespace arciem;

namespace arciem {

angle_t normalize_angle(angle_t a)
{
	if(a > two_pi) {
		a -= two_pi;
		if (a > two_pi) {
			a = fmod(a, two_pi);
		}
	} else if(a < 0.0) {
		a += two_pi;
		if(a < 0.0) {
			a = fmod(a, two_pi);
		}
	}
	
	return a;
}

} // namespace