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

#ifndef ARCIEM_POINT2_LIST_HPP
#define ARCIEM_POINT2_LIST_HPP

#include "point2.hpp"

#include <deque>
#include <string>

namespace arciem {

class point2_list : public std::deque<point2> {
public:
	std::string to_string() const;
};

} // namespace

#endif // ARCIEM_POINT2_LIST_HPP