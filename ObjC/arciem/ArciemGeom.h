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

#include <arciem/geometry/line2.hpp>
#import <CoreGraphics/CoreGraphics.h>

inline arciem::point2 to_arciem(CGPoint p) { return arciem::point2(p.x, p.y); }
inline arciem::line2 to_arciem(CGPoint p1, CGPoint p2) { return arciem::line2(to_arciem(p1), to_arciem(p2)); }
inline CGPoint to_quartz(arciem::point2 const& p) { return CGPointMake(p.x, p.y); }
