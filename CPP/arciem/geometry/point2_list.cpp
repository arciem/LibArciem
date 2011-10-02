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

#include <arciem/geometry/point2_list.hpp>

#include <arciem/stringstreams.hpp>

using namespace std;

namespace arciem {

std::string point2_list::to_string() const
{
	outputstringstream o;
	
	o << "[";
	unsigned s = size();
	for(unsigned i = 0; i < s; ++i) {
		o << i << ":" << (*this)[i].to_string();
		if(i != s - 1) {
			o << " ";
		}
	}
	o << "]";
	
	return o.extract();
}

} // namespace