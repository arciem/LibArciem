//
//  Arciem.h
//  Arciem
//
//  Created by Robert McNally on 2/12/13.
//  Copyright (c) 2013 Arciem LLC. All rights reserved.
//

#include "line2.hpp"
#import <CoreGraphics/CoreGraphics.h>

inline arciem::point2 to_arciem(CGPoint p) { return arciem::point2(p.x, p.y); }
inline arciem::line2 to_arciem(CGPoint p1, CGPoint p2) { return arciem::line2(to_arciem(p1), to_arciem(p2)); }
inline CGPoint to_quartz(arciem::point2 const& p) { return CGPointMake(p.x, p.y); }
