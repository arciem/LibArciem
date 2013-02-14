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

#import "Geom.h"


@implementation Geom

+ (CGRect)alignRectMinX:(CGRect)r toX:(CGFloat)x
{
	CGRect f = r;
	f.origin.x = x;
	return f;
}

+ (CGRect)alignRectMidX:(CGRect)r toX:(CGFloat)x
{
	CGRect f = r;
	f.origin.x = x - (r.size.width / 2);
	return f;
}

+ (CGRect)alignRectMaxX:(CGRect)r toX:(CGFloat)x
{
	CGRect f = r;
	f.origin.x = x - r.size.width;
	return f;
}

+ (CGRect)alignRectMinY:(CGRect)r toY:(CGFloat)y
{
	CGRect f = r;
	f.origin.y = y;
	return f;
}

+ (CGRect)alignRectMidY:(CGRect)r toY:(CGFloat)y
{
	CGRect f = r;
	f.origin.y = y - (r.size.height / 2);
	return f;
}

+ (CGRect)alignRectMaxY:(CGRect)r toY:(CGFloat)y
{
	CGRect f = r;
	f.origin.y = y - r.size.height;
	return f;
}

+ (CGRect)alignRectMid:(CGRect)r toPoint:(CGPoint)p
{
	CGRect f = r;
	f.origin.x = p.x - (r.size.width / 2);
	f.origin.y = p.y - (r.size.height / 2);
	return f;
}

+ (CGRect)alignRectMidX:(CGRect)r toRectMidX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x + (r2.size.width - r.size.width) / 2.0;
	return f;
}

+ (CGRect)alignRectMidY:(CGRect)r toRectMidY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y + (r2.size.height - r.size.height) / 2.0;
	return f;
}

+ (CGRect)alignRectMid:(CGRect)r toRectMid:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x + (r2.size.width - r.size.width) / 2.0;
	f.origin.y = r2.origin.y + (r2.size.height - r.size.height) / 2.0;
	return f;
}

+ (CGRect)alignRectMinX:(CGRect)r toRectMinX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x;
	return f;
}

+ (CGRect)alignRectMaxX:(CGRect)r toRectMinX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x - r.size.width;
	return f;
}

+ (CGRect)alignRectMinX:(CGRect)r toRectMaxX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x + r2.size.width;
	return f;
}

+ (CGRect)alignRectMaxX:(CGRect)r toRectMaxX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x + r2.size.width - r.size.width;
	return f;
}

+ (CGRect)alignRectMidX:(CGRect)r toRectMinX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x - r.size.width / 2.0;
	return f;
}

+ (CGRect)alignRectMidX:(CGRect)r toRectMaxX:(CGRect)r2
{
	CGRect f = r;
	f.origin.x = r2.origin.x + r2.size.width - r.size.width / 2.0;
	return f;
}

+ (CGRect)alignRectMinY:(CGRect)r toRectMinY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y;
	return f;
}

+ (CGRect)alignRectMaxY:(CGRect)r toRectMinY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y - r.size.height;
	return f;
}

+ (CGRect)alignRectMinY:(CGRect)r toRectMaxY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y + r2.size.height;
	return f;
}

+ (CGRect)alignRectMaxY:(CGRect)r toRectMaxY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y + r2.size.height - r.size.height;
	return f;
}

+ (CGRect)alignRectMidY:(CGRect)r toRectMinY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y - r.size.height / 2.0;
	return f;
}

+ (CGRect)alignRectMidY:(CGRect)r toRectMaxY:(CGRect)r2
{
	CGRect f = r;
	f.origin.y = r2.origin.y + r2.size.height - r.size.height / 2.0;
	return f;
}

+ (CGRect)insetRectMinX:(CGRect)r by:(CGFloat)dx
{
	CGRect f = r;
	f.origin.x = r.origin.x + dx;
	f.size.width = r.size.width - dx;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)insetRectMaxX:(CGRect)r by:(CGFloat)dx
{
	CGRect f = r;
	f.size.width = r.size.width - dx;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)insetRectMinY:(CGRect)r by:(CGFloat)dy
{
	CGRect f = r;
	f.origin.y = r.origin.y + dy;
	f.size.height = r.size.height - dy;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)insetRectMaxY:(CGRect)r by:(CGFloat)dy
{
	CGRect f = r;
	f.size.height = r.size.height - dy;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)setRectMinX:(CGRect)r to:(CGFloat)x
{
	CGRect f = r;
	CGFloat d = r.origin.x - x;
	f.origin.x = x;
	f.size.width = r.size.width + d;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)setRectMaxX:(CGRect)r to:(CGFloat)x
{
	CGRect f = r;
	CGFloat d = CGRectGetMaxX(r) - x;
	f.size.width = r.size.width - d;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)setRectMinY:(CGRect)r to:(CGFloat)y
{
	CGRect f = r;
	CGFloat d = r.origin.y - y;
	f.origin.y = y;
	f.size.height = r.size.height + d;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)setRectMaxY:(CGRect)r to:(CGFloat)y
{
	CGRect f = r;
	CGFloat d = CGRectGetMaxY(r) - y;
	f.size.height = r.size.height - d;
	f = CGRectStandardize(f);
	return f;
}

+ (CGRect)setRectWidth:(CGRect)r to:(CGFloat)w
{
	CGRect f = r;
	f.size.width = w;
	return f;
}

+ (CGRect)setRectHeight:(CGRect)r to:(CGFloat)h
{
	CGRect f = r;
	f.size.height = h;
	return f;
}

+ (CGFloat)scaleForAspectFitSize:(CGSize)s withinSize:(CGSize)s2
{
	CGFloat xScale = s2.width / s.width;
	CGFloat yScale = s2.height / s.height;
	CGFloat scale = fminf(xScale, yScale);
	return scale;
}

+ (CGSize)aspectFitSize:(CGSize)s withinSize:(CGSize)s2
{
	CGFloat scale = [Geom scaleForAspectFitSize:s withinSize:s2];
	CGSize f = CGSizeMake(s.width * scale, s.height * scale);
	return f;
}

+ (CGFloat)scaleForAspectFillSize:(CGSize)s withinSize:(CGSize)s2
{
	CGFloat xScale = s2.width / s.width;
	CGFloat yScale = s2.height / s.height;
	CGFloat scale = fmaxf(xScale, yScale);
	return scale;
}

+ (CGSize)aspectFillSize:(CGSize)s withinSize:(CGSize)s2
{
	CGFloat scale = [Geom scaleForAspectFillSize:s withinSize:s2];
	CGSize f = CGSizeMake(s.width * scale, s.height * scale);
	return f;
}

+ (CGPoint)rectMinXMinY:(CGRect)r
{
	return CGPointMake(CGRectGetMinX(r), CGRectGetMinY(r));
}

+ (CGPoint)rectMidXMinY:(CGRect)r
{
	return CGPointMake(CGRectGetMidX(r), CGRectGetMinY(r));
}

+ (CGPoint)rectMaxXMinY:(CGRect)r
{
	return CGPointMake(CGRectGetMaxX(r), CGRectGetMinY(r));
}

+ (CGPoint)rectMinXMidY:(CGRect)r
{
	return CGPointMake(CGRectGetMinX(r), CGRectGetMidY(r));
}

+ (CGPoint)rectMidXMidY:(CGRect)r
{
	return CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
}

+ (CGPoint)rectMaxXMidY:(CGRect)r
{
	return CGPointMake(CGRectGetMaxX(r), CGRectGetMidY(r));
}

+ (CGPoint)rectMinXMaxY:(CGRect)r
{
	return CGPointMake(CGRectGetMinX(r), CGRectGetMaxY(r));
}

+ (CGPoint)rectMidXMaxY:(CGRect)r
{
	return CGPointMake(CGRectGetMidX(r), CGRectGetMaxY(r));
}

+ (CGPoint)rectMaxXMaxY:(CGRect)r
{
	return CGPointMake(CGRectGetMaxX(r), CGRectGetMaxY(r));
}

+ (CGFloat)rectMidX:(CGRect)r
{
	return CGRectGetMidX(r);
}

+ (CGFloat)rectMidY:(CGRect)r
{
	return CGRectGetMidY(r);
}

+ (CGPoint)rectMid:(CGRect)r
{
	return CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
}

+ (CGSize)scaleSize:(CGSize)s bySX:(CGFloat)sx SY:(CGFloat)sy
{
	CGSize f;
	f.width = s.width * sx;
	f.height = s.height * sy;
	return f;
}

+ (CGPoint)scalePoint:(CGPoint)p relativeToPoint:(CGPoint)p2 bySX:(CGFloat)sx SY:(CGFloat)sy
{
	CGPoint f = p;
	f.x = (p.x - p2.x) * sx + p2.x;
	f.y = (p.y - p2.y) * sy + p2.y;
	return f;
}

+ (CGRect)scaleRect:(CGRect)r relativeToPoint:(CGPoint)p bySX:(CGFloat)sx SY:(CGFloat)sy
{
	CGRect f = r;
	f.origin = [Geom scalePoint:f.origin relativeToPoint:p bySX:sx SY:sy];
	f.size = [Geom scaleSize:f.size bySX:sx SY:sy];
	return f;
}

+ (CGSize)point:(CGPoint)p2 minusPoint:(CGPoint)p1
{
	return CGSizeMake(p2.x - p1.x, p2.y - p1.y);
}

+ (CGFloat)radiansWithDegrees:(CGFloat)d
{
	return d / 180.0 * M_PI;
}

+ (CGFloat)degreesWithRadians:(CGFloat)r
{
	return r / M_PI * 180.0;
}

@end
