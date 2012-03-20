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

#import "MapKitUtils.h"

@implementation NSValue(MapKitUtils)

+ (NSValue*)valueWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	return [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
}

- (CLLocationCoordinate2D)coordinateValue
{
	CLLocationCoordinate2D coordinate;
	[self getValue:&coordinate];
	return coordinate;
}

@end

CLLocationCoordinate2D CentroidOfCoordinates(NSArray* coordinateValues)
{
	CLLocationCoordinate2D result = kCLLocationCoordinate2DInvalid;

	BOOL first = YES;
	for(NSValue* val in coordinateValues) {
		CLLocationCoordinate2D coord = [val coordinateValue];
		if(first) {
			result = coord;
			first = NO;
		} else {
			result.latitude += coord.latitude;
			result.longitude += coord.longitude;
		}
	}
	
	NSUInteger count = coordinateValues.count;
	if(count > 0) {
		result.latitude /= count;
		result.longitude /= count;
	}
	
	return result;
}

NSString* NSStringFromMKMapRect(MKMapRect rect)
{
	return [NSString stringWithFormat:@"{{%@,%@},{%@,%@}}",
			[NSNumber numberWithDouble:rect.origin.x],
			[NSNumber numberWithDouble:rect.origin.y],
			[NSNumber numberWithDouble:rect.size.width],
			[NSNumber numberWithDouble:rect.size.height]
			];
}