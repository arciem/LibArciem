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

#import "CShadowView.h"
#import "CGUtils.h"
#import "CObserver.h"

@import QuartzCore;

@interface CShadowView ()

@property (nonatomic) CAGradientLayer* shadowLayer;
@property (nonatomic) CObserver* edgeObserver;

@end

@implementation CShadowView

- (void)setup {
	[super setup];
    
    self.layoutView = YES;

    self.userInteractionEnabled = NO;

	CGColorRef clearColor = CreateColorWithGray(0, 0);
	CGColorRef blackColor = CreateColorWithGray(0, 0.25);
    
	self.shadowLayer = [CAGradientLayer new];
	self.shadowLayer.needsDisplayOnBoundsChange = YES;
	self.shadowLayer.colors = @[(__bridge_transfer id)blackColor, (__bridge_transfer id)clearColor];
	[self.layer addSublayer:self.shadowLayer];

    BSELF;
    self.edgeObserver = [CObserver newObserverWithKeyPath:@"edge" ofObject:self action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
        [bself syncToEdge];
    }];
}

- (void)dealloc {
    self.shadowLayer = nil;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.shadowLayer.frame = self.bounds;
}

- (void)syncToEdge {
    switch(self.edge) {
        case CShadowViewEdgeTop:
            self.shadowLayer.startPoint = CGPointMake(0.5, 1.0);
            self.shadowLayer.endPoint = CGPointMake(0.5, 0.0);
            break;
        case CShadowViewEdgeBottom:
            self.shadowLayer.startPoint = CGPointMake(0.5, 0.0);
            self.shadowLayer.endPoint = CGPointMake(0.5, 1.0);
            break;
        case CShadowViewEdgeLeft:
            self.shadowLayer.startPoint = CGPointMake(1.0, 0.5);
            self.shadowLayer.endPoint = CGPointMake(0.0, 0.5);
            break;
        case CShadowViewEdgeRight:
            self.shadowLayer.startPoint = CGPointMake(0.0, 0.5);
            self.shadowLayer.endPoint = CGPointMake(1.0, 0.5);
            break;
    }
}

@end
