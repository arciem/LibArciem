/*******************************************************************************
 
 Copyright 2013 Arciem LLC
 
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

#import "CButton.h"
#import "UIImageUtils.h"
#import "DeviceUtils.h"

@implementation CButton

@synthesize tintedImage = _tintedImage;
@synthesize defaultTintColor = _defaultTintColor;

- (UIImage *)tintedImage {
    return _tintedImage;
}

- (void)setTintedImage:(UIImage *)tintedImage {
    _tintedImage = tintedImage;
    [self syncToTintColor];
}

- (void)syncToTintColor {
    UIImage *image = _tintedImage;
    UIColor *color = self.tintColor;
    if(!IsOSVersionAtLeast7() || color == nil) {
        color = self.defaultTintColor;
    }
    if(color != nil && _tintedImage != nil) {
        image = [UIImage newImageWithShapeImage:image tintColor:color];
    }
    [self setImage:image forState:UIControlStateNormal];
}

- (UIColor *)defaultTintColor {
    return _defaultTintColor;
}

- (void)setDefaultTintColor:(UIColor *)defaultTintColor {
    _defaultTintColor = defaultTintColor;
    [self syncToTintColor];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self syncToTintColor];
}

@end
