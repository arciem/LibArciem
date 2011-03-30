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

#import "DeviceUtils.h"

BOOL IsPhone()
{
	return UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;
}

BOOL IsPad()
{
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

BOOL IsPortrait()
{
	return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

BOOL IsLandscape()
{
	return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

BOOL IsHiDPI()
{
	return ScreenScale() > 1.0;
}

BOOL IsOSVersionAtLeast(NSString *minVerStr)
{
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	return [currSysVer compare:minVerStr options:NSNumericSearch] != NSOrderedAscending;
}

CGFloat ScreenScale()
{
	static CGFloat scale = 0.0;

	if(scale == 0.0) {
		UIScreen* mainScreen = [UIScreen mainScreen];
		if([mainScreen respondsToSelector:@selector(scale)]) {
			scale = mainScreen.scale;
		} else {
			scale = 1.0;
		}
	}

	return scale;
}

BOOL IsMultitasking()
{
	BOOL isMultitasking = NO;

	UIDevice* device = [UIDevice currentDevice];
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
	   isMultitasking = device.multitaskingSupported;
	
	return isMultitasking;
}

NSString* DeviceUUID()
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}

NSString* StringByAppendingDeviceSuffix(NSString* s)
{
	s = [s stringByAppendingString:IsPhone() ? @"_Phone" : @"_Pad"];
//	CLogDebug(nil, @"string: %@", s);
	return s;
}

id<NSObject> DeviceClassAlloc(NSString* className)
{
	id instance = nil;
	
	className = StringByAppendingDeviceSuffix(className);
	Class cls = NSClassFromString(className);
	if(cls != nil) {
		return [cls alloc];
	}
	
	return instance;
}

@implementation NSBundle (BundlePlatformAdditions)

- (NSArray *)loadDeviceNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options
{
	NSArray* result = [self loadNibNamed:StringByAppendingDeviceSuffix(name) owner:owner options:options];
	if(result == nil) {
		result = [self loadNibNamed:name owner:owner options:options];
	}
	return result;
}

@end
