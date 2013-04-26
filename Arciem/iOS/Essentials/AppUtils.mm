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

#import "AppUtils.h"
#import "StringUtils.h"

@interface UIApplication ()

@property(readonly, nonatomic) NSDictionary* infoDictionary;

@end

@implementation UIApplication (AppUtils)

- (NSDictionary*)infoDictionary
{
    static NSDictionary* dict = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString* infoPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        dict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    });
    return dict;
}

- (NSString*)versionAndBuildString
{
    NSString* versionString = self.infoDictionary[@"CFBundleShortVersionString"];
    if(IsEmptyString(versionString)) versionString = @"Unknown";
    NSString* buildNumberString = self.infoDictionary[@"CFBundleVersion"];
    if(IsEmptyString(buildNumberString)) buildNumberString = @"Unknown";
    return [NSString stringWithFormat:@"%@ (%@)", versionString, buildNumberString];
}

- (NSString*)displayName
{
    return self.infoDictionary[@"CFBundleDisplayName"];
}

@end
