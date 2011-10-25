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

#include <arciem/geometry/delta3.hpp>
#include <arciem/stringstreams.hpp>

namespace arciem {

delta3 const& delta3::zero() { static delta3* d = new delta3(); return *d; }
delta3 const& delta3::x_axis() { static delta3* d = new delta3(1, 0, 0); return *d; }
delta3 const& delta3::y_axis() { static delta3* d = new delta3(0, 1, 0); return *d; }
delta3 const& delta3::z_axis() { static delta3* d = new delta3(0, 0, 1); return *d; }

std::string delta3::to_string() const
{
	outputstringstream o;
	
	o << "[dx:" << dx << " dy:" << dy  << " dz:" << dz << "]";
	
	return o.extract();
}

}