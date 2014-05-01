/*******************************************************************************
 
 Copyright 2014 Arciem LLC
 
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

@class CTextureAtlasImage;

@interface CTextureAtlasSubimage : NSObject

- (instancetype)initWithAtlasImage:(CTextureAtlasImage *)image dictionary:(NSDictionary *)dict;

- (void)drawInRect:(CGRect)rect;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) CGSize sourceSize;
@property (readonly, nonatomic, getter = isOpaque) BOOL opaque;
@property (readonly, nonatomic) UIImage *image;
@end
