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

#ifndef ARCIEM_STRINGSTREAMS_HPP
#define ARCIEM_STRINGSTREAMS_HPP

#ifdef ARCIEM_NO_STRINGSTREAM
	#include <strstream>

	namespace arciem {

	class inputstringstream : public std::istrstream {
	public:
		explicit inputstringstream(std::string const& s) : std::istrstream(s.c_str()) { }
	};

	class outputstringstream : public std::ostrstream {
	public:
		explicit outputstringstream() : std::ostrstream() { }
		std::string extract() { (*this) << std::ends; std::string s(str()); freeze(false); return s; }
	};

	} // namespace arciem
#else
	#include <sstream>

	namespace arciem {
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wweak-vtables"
	class inputstringstream : public std::istringstream {
	public:
		explicit inputstringstream(std::string const& s) : std::istringstream(s) { }
	};

	class outputstringstream : public std::ostringstream {
	public:
		explicit outputstringstream() : std::ostringstream() { }
		std::string extract() { return str(); }
	};
#pragma clang diagnostic pop
	
	} // namespace arciem
#endif

#endif // ARCIEM_STRINGSTREAMS_HPP
