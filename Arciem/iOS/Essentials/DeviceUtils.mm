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
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "ObjectUtils.h"

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

// uniqueIdentifier is now deprecated
#if 0
NSString* DeviceUUID()
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}
#endif

NSString* DeviceVendor()
{
	return @"Apple";
}

NSString* DeviceModel()
{
	UIDevice *device = [UIDevice currentDevice];
//	NSString* model = [device model];
	NSString* OSName = [device systemName];
	NSString* OSVersion = [device systemVersion];

	return [NSString stringWithFormat:@"%@ %@", OSName, OSVersion];
}

NSString* StringByAppendingDeviceSuffix(NSString* s)
{
	s = [s stringByAppendingString:IsPhone() ? @"~iPhone" : @"~iPad"];
//	CLogDebug(nil, @"string: %@", s);
	return s;
}

id<NSObject> DeviceClassAlloc(NSString* className)
{
	className = StringByAppendingDeviceSuffix(className);
	id instance = ClassAlloc(className);
	
	return instance;
}

NSString* APNSDeviceToken(NSData* s)
{
	NSString* deviceToken = [[s description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];	
	return deviceToken;
}

// This only returns the local address of the device, which is probably behind a NAT.
NSString* DeviceIPAddress()
{
	NSString *result = nil;

	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;

	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0) {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL) {
			if(temp_addr->ifa_addr->sa_family == AF_INET) {
				NSString* interfaceName = @(temp_addr->ifa_name);
				NSString* address = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
				CLogDebug(nil, @"interface:%@ address:%@", interfaceName, address);
				if([interfaceName isEqualToString:@"en0"]) {
					// Interface is en0 which is the wifi connection on the iPhone
					result = address;
					break;
				} else if([interfaceName isEqualToString:@"pdp_ip0"]) {
					// Interface is pdp_ip0 which is the cell connection on the iPhone
					result = address;
					break;
				}
			}

			temp_addr = temp_addr->ifa_next;
		}
	}

	// Free memory
	freeifaddrs(interfaces);

	return result;
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
