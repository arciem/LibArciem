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

#import "CGLView.h"

@interface CGLView ()

@property(strong, nonatomic) CADisplayLink* displayLink;

@end

@implementation CGLView

@synthesize renderer = renderer_;
@synthesize displayLink = displayLink_;
@dynamic animating;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setup
{
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									nil];

	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
	self.animating = NO;
	[self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder])) {
		[self setup];
    }
	
    return self;
}

- (void)drawView:(id)sender
{
    [self.renderer render];
}

- (void)layoutSubviews
{
	[self.renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (void)dealloc
{
	[self.displayLink invalidate];

	self.renderer = nil;
	self.displayLink = nil;
}

- (BOOL)isAnimating
{
	return !self.displayLink.paused;
}

- (void)setAnimating:(BOOL)animating
{
	self.displayLink.paused = !animating;
}

@end
