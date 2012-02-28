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

#import <UIKit/UIKit.h>

BOOL IsPhone();
BOOL IsPad();
BOOL IsPortrait();
BOOL IsLandscape();
BOOL IsMultitasking();

BOOL IsHiDPI();
CGFloat ScreenScale();

// NSString* DeviceUUID(); // uniqueIdentifier is now deprecated
NSString* DeviceVendor();
NSString* DeviceModel();
NSString* DeviceIPAddress();
NSString* StringByAppendingDeviceSuffix(NSString* s);

BOOL IsOSVersionAtLeast(NSString *minVerStr);

id<NSObject> DeviceClassAlloc(NSString* className);
NSString* APNSDeviceToken(NSData* s);

@interface NSBundle (BundlePlatformAdditions)

- (NSArray *)loadDeviceNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options;

@end

@interface UIViewController (BundlePlatformAdditions)
@end