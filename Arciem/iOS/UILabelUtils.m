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
#import <math.h>

@implementation UILabel (UILabelUtils)

#if 0
- (void)adjustFontSizeToFit:(CGFloat)largeFontSize
{
	UIFont* font = nil;
	CGFloat maxHeight = self.bounds.size.height;
//	CGFloat maxWidth = self.bounds.size.width;
    CGSize constraintSize = CGSizeMake(self.bounds.size.width, MAXFLOAT);
	for(CGFloat fontSize = largeFontSize; fontSize >= self.font.pointSize * self.minimumScaleFactor; --fontSize) {
		font = [self.font fontWithSize:fontSize];
		CGSize size = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:self.lineBreakMode];
		CGFloat lines = size.height / font.leading;
		if(self.numberOfLines != 0 && lines > self.numberOfLines) {
			continue;
		}
		size.height -= font.descender;
		if(size.height <= maxHeight) {
			break;
		}
	}
	self.font = font;
}
#endif

- (void)adjustFontSizeToFit:(CGFloat)largeFontSize
{
    CGSize constraintSize = self.bounds.size;
    NSDictionary *attr = @{
                           NSFontAttributeName: self.font
                           };
    NSStringDrawingContext *context = [NSStringDrawingContext new];
    context.minimumScaleFactor = self.minimumScaleFactor;
    [self.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:context];
    CGFloat actualScaleFactor = context.actualScaleFactor;
    self.font = [self.font fontWithSize:self.font.pointSize * actualScaleFactor];
}

+ (CGSize)maxSizeOfStrings:(NSArray*)strings withFont:(UIFont*)font forWidth:(CGFloat)width
{
    __block CGSize maxSize = CGSizeZero;
    
    [strings enumerateObjectsUsingBlock:^(id str, NSUInteger idx, BOOL *stop) {
        NSMutableAttributedString *string;
        if([str isKindOfClass:[NSAttributedString class]]) {
            string = [str mutableCopy];
        } else {
            string = [[NSMutableAttributedString alloc] initWithString:str];
        }
        [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
        CGRect rect = [string boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize size = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
        maxSize.width = fmax(maxSize.width, size.width);
        maxSize.height = fmax(maxSize.height, size.height);
    }];

    return maxSize;
}

@end
