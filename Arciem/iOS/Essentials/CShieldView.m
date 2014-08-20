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

#import "CShieldView.h"
#import "CGUtils.h"
#import "Geom.h"
#import "UIViewUtils.h"
#import "CSerializer.h"
#import "ThreadUtils.h"

static NSString* const kClassLogTag = @"SHIELD_VIEW";

@interface CShieldView ()

@property (weak, nonatomic) UIView *parentView;
@property (nonatomic) CSerializer *serializer;

@end

@implementation CShieldView

+ (void)initialize {
    //    CLogSetTagActive(kClassLogTag, YES);
}

- (instancetype)initWithParentView:(UIView *)parentView {
    if(self = [super initWithFrame:parentView.bounds]) {
        self.serializer = [CSerializer newSerializerWithName:@"CShieldView Serializer"];
        self.parentView = parentView;
    }
    return self;
}

- (void)setup {
	[super setup];
	
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
    //	self.userInteractionEnabled = NO;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    //	self.debugColor = [UIColor whiteColor];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    
	CGContextRef context = UIGraphicsGetCurrentContextChecked();
	
	CGContextSaveGState(context);
    ContextFillShieldGradient(context, self.bounds);
	CGContextRestoreGState(context);
}

- (void)addToParentDelayed {
    [self.serializer dispatchOnMainThread:^{
        CLogTrace(kClassLogTag, @"%@ addToParentDelayed", self);
        [self performSelector:@selector(addToParent) withObject:nil afterDelay:0.5];
    }];
}

- (void)addToParent {
    [self.serializer dispatchOnMainThread:^{
        CLogTrace(kClassLogTag, @"%@ addToParent", self);
        [self.parentView addSubview:self animated:YES];
    }];
}

- (void)removeFromParent {
    [self.serializer dispatchOnMainThread:^{
        CLogTrace(kClassLogTag, @"%@ removeFromParent", self);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addToParent) object:nil];
        [self removeFromSuperviewAnimated:YES];
    }];
}

@end