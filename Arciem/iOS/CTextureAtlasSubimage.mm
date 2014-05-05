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

#import <QuartzCore/QuartzCore.h>
#import "CTextureAtlasSubimage.h"
#import "CTextureAtlasImage.h"
#import "UIImageUtils.h"

#define DEBUG_DRAW

static NSRegularExpression *sRemoveExtensionRegularExpression;

@interface CTextureAtlasSubimage ()

@property (weak, readonly, nonatomic) CTextureAtlasImage *atlasImage;
@property (readonly, nonatomic) CGSize offset;
@property (readonly, nonatomic) CGRect sourceRect;
@property (readonly, nonatomic) BOOL rotated;

@end

@implementation CTextureAtlasSubimage

@synthesize atlasImage = _atlasImage;
@synthesize name = _name;
@synthesize offset = _offset;
@synthesize sourceSize = _sourceSize;
@synthesize sourceRect = _sourceRect;
@synthesize rotated = _rotated;
@synthesize opaque = _opaque;
@synthesize image = _image;

- (instancetype)initWithAtlasImage:(CTextureAtlasImage *)atlasImage dictionary:(NSDictionary *)dict {
    if(self = [super init]) {
        
        if(sRemoveExtensionRegularExpression == nil) {
            NSError *error;
            NSString *pattern = @"^(.*?)\\.(png|gif|jpg|jpeg)$";
            sRemoveExtensionRegularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        }
        
        _atlasImage = atlasImage;
        _name = dict[@"name"];
        _name = [sRemoveExtensionRegularExpression stringByReplacingMatchesInString:_name options:0 range:NSMakeRange(0, _name.length) withTemplate:@"$1" ];
        _opaque = [dict [@"isFullyOpaque"] boolValue];
        _offset = CGSizeFromString(dict[@"spriteOffset"]);
        _sourceSize = CGSizeFromString(dict[@"spriteSourceSize"]);
        _sourceRect = CGRectFromString(dict[@"textureRect"]);
        _rotated = [dict[@"textureRotated"] boolValue];
    }
    return self;
}

- (void)drawInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawInContext:context rect:rect];
}

- (void)drawInContext:(CGContextRef)context rect:(CGRect)destRect {
    UIImage *atlasImage = self.atlasImage.image;

    CGContextSaveGState(context);

#ifdef DEBUG_DRAW
    [[UIColor blueColor] set];
    UIRectFill(destRect);

    CGContextSaveGState(context);
#endif
    CGRect clipRect = CGRectInset(destRect, self.offset.width / self.sourceSize.width * destRect.size.width, self.offset.height / self.sourceSize.height * destRect.size.height);
    CGContextClipToRect(context, clipRect);
#ifdef DEBUG_DRAW
    [[UIColor greenColor] set];
    UIRectFill(destRect);
    CGContextRestoreGState(context);
#endif

    CGSize offset = self.offset;
    if(self.rotated) {
        CGContextTranslateCTM(context, 0.0, self.sourceSize.height);
        CGContextRotateCTM(context, -M_PI_2);
        offset = CGSizeMake(self.offset.height, self.offset.width);
    }

    CGFloat xTranslateFactor = -self.sourceRect.origin.x + offset.width;
    CGFloat yTranslateFactor = -self.sourceRect.origin.y + offset.height;
    CGContextTranslateCTM(context, xTranslateFactor, yTranslateFactor);

    CGFloat xScaleFactor = atlasImage.size.width / destRect.size.width;
    CGFloat yScaleFactor = atlasImage.size.height / destRect.size.height;
    CGContextScaleCTM(context, xScaleFactor, yScaleFactor);
    
    CGContextTranslateCTM(context, 0.0, CGRectGetMaxY(destRect));
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, destRect, atlasImage.CGImage);

    CGContextRestoreGState(context);
}

- (UIImage *)image {
    if(_image == nil) {
        CGContextRef context = [UIImage beginImageContextWithSize:self.sourceSize opaque:self.opaque scale:0 flipped:NO];
        [self drawInContext:context rect:CGRectMake(0, 0, self.sourceSize.width, self.sourceSize.height)];
        _image = [UIImage endImageContext];
    }
    
    return _image;
}

@end
