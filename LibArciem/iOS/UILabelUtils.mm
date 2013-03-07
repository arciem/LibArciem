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

#import "UILabelUtils.h"
#import "Geom.h"
#import <algorithm>

@implementation UILabel (UILabelUtils)

- (void)adjustFontSizeToFit:(CGFloat)largeFontSize
{
	UIFont* font = nil;
	CGFloat maxHeight = self.bounds.size.height;
	CGFloat maxWidth = self.bounds.size.width;
	for(CGFloat fontSize = largeFontSize; fontSize >= self.minimumFontSize; --fontSize) {
		font = [self.font fontWithSize:fontSize];
		CGSize size = [self.text sizeWithFont:font constrainedToSize:self.bounds.size lineBreakMode:self.lineBreakMode];
		CGFloat lines = size.height / font.leading;
		if(lines > self.numberOfLines) {
			continue;
		}
		size.height -= font.descender;
		if(size.height < maxHeight && size.width < maxWidth) {
			break;
		}
	}
	self.font = font;
}

+ (CGSize)maxSizeOfStrings:(NSArray*)strings withFont:(UIFont*)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode
{
    __block CGSize maxSize = CGSizeZero;
    
    [strings enumerateObjectsUsingBlock:^(NSString* string, NSUInteger idx, BOOL *stop) {
        CGSize size = [string sizeWithFont:font forWidth:width lineBreakMode:lineBreakMode];
        maxSize.width = std::max(maxSize.width, size.width);
        maxSize.height = std::max(maxSize.height, size.height);
    }];

    return maxSize;
}

@end
