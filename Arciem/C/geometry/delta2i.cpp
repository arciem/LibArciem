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

#include "delta2i.hpp"
#include "delta2.hpp"

#include "stringstreams.hpp"

namespace arciem {

delta2i const& delta2i::zero() { static delta2i* d = new delta2i(); return *d; }

delta2i::delta2i(const delta2& d) : dx((int)d.dx), dy((int)d.dy) { }

string delta2i::to_string() const
{
	outputstringstream o;
	
	o << "[dx:" << dx << " dy:" << dy << "]";
	
	return o.extract();
}

}