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

@import CoreGraphics;

@interface Geom : NSObject

+ (CGRect)alignRectMinX:(CGRect)r toX:(CGFloat)x;
+ (CGRect)alignRectMidX:(CGRect)r toX:(CGFloat)x;
+ (CGRect)alignRectMaxX:(CGRect)r toX:(CGFloat)x;
+ (CGRect)alignRectMinY:(CGRect)r toY:(CGFloat)y;
+ (CGRect)alignRectMidY:(CGRect)r toY:(CGFloat)y;
+ (CGRect)alignRectMaxY:(CGRect)r toY:(CGFloat)y;

+ (CGRect)alignRectMid:(CGRect)r toPoint:(CGPoint)p;

+ (CGRect)alignRectMidX:(CGRect)r toRectMidX:(CGRect)r2;
+ (CGRect)alignRectMidY:(CGRect)r toRectMidY:(CGRect)r2;
+ (CGRect)alignRectMid:(CGRect)r toRectMid:(CGRect)r2;
+ (CGRect)alignRectMinX:(CGRect)r toRectMinX:(CGRect)r2;
+ (CGRect)alignRectMaxX:(CGRect)r toRectMinX:(CGRect)r2;
+ (CGRect)alignRectMinX:(CGRect)r toRectMaxX:(CGRect)r2;
+ (CGRect)alignRectMaxX:(CGRect)r toRectMaxX:(CGRect)r2;
+ (CGRect)alignRectMidX:(CGRect)r toRectMinX:(CGRect)r2;
+ (CGRect)alignRectMidX:(CGRect)r toRectMaxX:(CGRect)r2;
+ (CGRect)alignRectMinY:(CGRect)r toRectMinY:(CGRect)r2;
+ (CGRect)alignRectMaxY:(CGRect)r toRectMinY:(CGRect)r2;
+ (CGRect)alignRectMinY:(CGRect)r toRectMaxY:(CGRect)r2;
+ (CGRect)alignRectMaxY:(CGRect)r toRectMaxY:(CGRect)r2;
+ (CGRect)alignRectMidY:(CGRect)r toRectMinY:(CGRect)r2;
+ (CGRect)alignRectMidY:(CGRect)r toRectMaxY:(CGRect)r2;

+ (CGRect)insetRectMinX:(CGRect)r by:(CGFloat)dx;
+ (CGRect)insetRectMaxX:(CGRect)r by:(CGFloat)dx;
+ (CGRect)insetRectMinY:(CGRect)r by:(CGFloat)dy;
+ (CGRect)insetRectMaxY:(CGRect)r by:(CGFloat)dy;

+ (CGRect)setRectMinX:(CGRect)r to:(CGFloat)x;
+ (CGRect)setRectMaxX:(CGRect)r to:(CGFloat)x;
+ (CGRect)setRectMinY:(CGRect)r to:(CGFloat)y;
+ (CGRect)setRectMaxY:(CGRect)r to:(CGFloat)y;

+ (CGRect)setRectWidth:(CGRect)r to:(CGFloat)w;
+ (CGRect)setRectHeight:(CGRect)r to:(CGFloat)h;

+ (CGFloat)scaleForAspectFitSize:(CGSize)s withinSize:(CGSize)s2;
+ (CGFloat)scaleForAspectFillSize:(CGSize)s withinSize:(CGSize)s2;
+ (CGSize)aspectFitSize:(CGSize)s withinSize:(CGSize)s2;
+ (CGSize)aspectFillSize:(CGSize)s withinSize:(CGSize)s2;

+ (CGPoint)rectMinXMinY:(CGRect)r;
+ (CGPoint)rectMidXMinY:(CGRect)r;
+ (CGPoint)rectMaxXMinY:(CGRect)r;
+ (CGPoint)rectMinXMidY:(CGRect)r;
+ (CGPoint)rectMidXMidY:(CGRect)r;
+ (CGPoint)rectMaxXMidY:(CGRect)r;
+ (CGPoint)rectMinXMaxY:(CGRect)r;
+ (CGPoint)rectMidXMaxY:(CGRect)r;
+ (CGPoint)rectMaxXMaxY:(CGRect)r;
+ (CGFloat)rectMidX:(CGRect)r;
+ (CGFloat)rectMidY:(CGRect)r;
+ (CGPoint)rectMid:(CGRect)r;

+ (CGSize)scaleSize:(CGSize)s bySX:(CGFloat)sx SY:(CGFloat)sy;
+ (CGPoint)scalePoint:(CGPoint)p relativeToPoint:(CGPoint)p2 bySX:(CGFloat)sx SY:(CGFloat)sy;
+ (CGRect)scaleRect:(CGRect)r relativeToPoint:(CGPoint)p bySX:(CGFloat)sx SY:(CGFloat)sy;

+ (CGSize)point:(CGPoint)p2 minusPoint:(CGPoint)p1;

+ (CGFloat)radiansWithDegrees:(CGFloat)d;
+ (CGFloat)degreesWithRadians:(CGFloat)r;

+ (CGFloat)binarySearchBetweenMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue epsilon:(CGFloat)epsilon test:(NSComparisonResult(^)(CGFloat value))test;

@end
