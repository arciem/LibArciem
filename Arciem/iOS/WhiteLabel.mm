/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "WhiteLabel.h"
#import "StringUtils.h"

#import <UIKit/UIKit.h>

@interface WhiteLabel ()

@property (nonatomic, readonly) NSCache* cache;
@property (nonatomic, readonly) NSDictionary* whiteLabelDict;

@end

@implementation WhiteLabel

@synthesize cache = _cache;
@synthesize whiteLabelDict = _whiteLabelDict;

+ (WhiteLabel*)sharedWhiteLabel
{
    static WhiteLabel* instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [WhiteLabel new];
    });
    return instance;
}

- (instancetype)init
{
    if(self = [super init]) {
        _cache = [NSCache new];
 
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* infoPath = [bundle pathForResource:@"Info" ofType:@"plist"];
        NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        NSString* whiteLabelName = info[@"WhiteLabelName"];
        NSString* whiteLabelPath = [bundle pathForResource:whiteLabelName ofType:@"plist"];
        _whiteLabelDict = [NSDictionary dictionaryWithContentsOfFile:whiteLabelPath];
    }
    
    return self;
}

- (UIColor*)processHSBColor:(NSString*)str
{
    UIColor* result;

    NSArray* components = [str componentsSeparatedByString:@","];
    
    CGFloat hue = [components[0] floatValue];
    CGFloat saturation = [components[1] floatValue];
    CGFloat brightness = [components[2] floatValue];
    CGFloat alpha = components.count < 4 ? 1.0 : [components[3] floatValue];
    
    result = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];

    return result;
}

- (UIColor*)processRGBColor:(NSString*)str
{
    UIColor* result;
    
    NSArray* components = [str componentsSeparatedByString:@","];
    
    CGFloat red = [components[0] floatValue];
    CGFloat green = [components[1] floatValue];
    CGFloat blue = [components[2] floatValue];
    CGFloat alpha = components.count < 4 ? 1.0 : [components[3] floatValue];
    
    result = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return result;
}

- (NSURL*)processURL:(NSString*)str
{
    NSURL* result = [NSURL URLWithString:str];
    return result;
}

- (UIImage*)processImage:(NSString*)str
{
    UIImage* result = [UIImage imageNamed:str];
    return result;
}

- (id)processObject:(id)obj
{
    if([obj isKindOfClass:[NSString class]]) {
        NSString* str = (NSString*)obj;
        NSArray* components = [str componentsSeparatedByString:@":"];
        if(components.count > 1) {
            NSString* scheme = components[0];
            NSString* body = [str substringFromIndex:scheme.length + 1];
            
            if([scheme isEqualToString:@"hsbColor"]) {
                obj = [self processHSBColor:body];
            } else if([scheme isEqualToString:@"rgbColor"]) {
                obj = [self processRGBColor:body];
            } else if([scheme isEqualToString:@"image"]) {
                obj = [self processImage:body];
            } else {
                obj = [self processURL:str];
            }
        }
    }
    
    return obj;
}

- (id)resourceForKey:(NSString*)key
{
    id result = [self.cache objectForKey:key];
    
    if(result == nil) {
        result = self.whiteLabelDict[key];
        if(result != nil) {
            result = [self processObject:result];
            NSAssert1(result != nil, @"Resource not found for key:%@", key);

            [self.cache setObject:result forKey:key];
        }
    }
    
    return result;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    id result = [self resourceForKey:key];
    if(result == nil) {
        result = [super valueForUndefinedKey:key];
    }
    return result;
}

- (NSString*)stringByReplacingTemplatesInString:(NSString*)str
{
    NSMutableString* mutableStr = [str mutableCopy];
    
    NSError* error = nil;
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"\\{(.*?)\\}" options:0 error:&error];
    NSInteger offset = 0;
    for(NSTextCheckingResult* result in [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)]) {
        NSRange resultRange = result.range;
        resultRange.location += offset;
        NSString* match = [regex replacementStringForResult:result inString:mutableStr offset:offset template:@"$1"];
        NSString* replacement = [self valueForKey:match];
        [mutableStr replaceCharactersInRange:resultRange withString:replacement];
        offset = offset + replacement.length - resultRange.length;
    }
    
    return [NSString stringWithString:mutableStr];
}

+ (NSString*)replaceTemplates:(NSString*)str
{
    return [[self sharedWhiteLabel] stringByReplacingTemplatesInString:str];
}

+ (id)resourceForKey:(NSString*)key
{
    return [[self sharedWhiteLabel] resourceForKey:key];
}

@end
