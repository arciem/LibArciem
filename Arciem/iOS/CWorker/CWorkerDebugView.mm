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

#import <QuartzCore/QuartzCore.h>
#import "CWorkerDebugView.h"
#import "UIViewUtils.h"
#import "ThreadUtils.h"
#import "UIColorUtils.h"

const CGFloat kCWorkerDebugViewFontSize = 14;
const CGFloat kCWorkerDebugViewMinimumFontSize = 8;

@interface CWorkerDebugView ()

@property (strong, nonatomic) UILabel* label;

@end

@implementation CWorkerDebugView

@synthesize worker = _worker;

+ (void)initialize
{
//	CLogSetTagActive(@"C_WORKER_DEBUG_VIEW", YES);
}

+ (void)setWidth:(CGFloat)width
{
	
}

- (id)initWithFrame:(CGRect)frame worker:(CWorker*)worker
{
	if(self = [super initWithFrame:frame]) {
		self.worker = worker;
		[self sizeToFit];
	}
	return self;
}

- (void)dealloc
{
//	CLogDebug(nil, @"%@ dealloc", self);
	self.worker = nil;
}

- (void)setup
{
	[super setup];
	
//	self.debugColor = [UIColor redColor];

//	self.backgroundColor = [[UIColor blueColor] colorWithAlpha:0.5];
	self.userInteractionEnabled = NO;
	self.layer.borderWidth = 0.5;

#if 0
	self.layer.shadowRadius = 0.0;
	self.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowOffset = CGSizeMake(0, 1.0);
#endif
	
	self.label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 0)];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.opaque = NO;
	self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.fontSize = kCWorkerDebugViewFontSize;
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.adjustsFontSizeToFitWidth = YES;
	self.label.minimumFontSize = kCWorkerDebugViewMinimumFontSize;
	self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:self.label];
}

- (void)syncToWorker
{
	@synchronized(self.worker) {
		self.label.text = self.worker.title;
		NSString* status = @"UNKNOWN";
		UIColor* backgroundColor = [UIColor grayColor];
		UIColor* textColor = [UIColor whiteColor];
		
		if(self.worker.isFinished) {
			status = @"FINISHED";
			if(self.worker.error == nil) {
				backgroundColor = [[UIColor greenColor] colorByDarkeningFraction:0.7];
			} else {
				backgroundColor = [[UIColor redColor] colorByDarkeningFraction:0.5];
			}
			textColor = [UIColor whiteColor];
			if(self.worker.isCancelled) {
				status = @"CANCELLED";
				backgroundColor = [UIColor blackColor];
				textColor = [UIColor whiteColor];
			}
		} else if(self.worker.isExecuting) {
			status = @"EXECUTING";
			backgroundColor = [[UIColor blueColor] colorByLighteningFraction:0.5];
			textColor = [UIColor blackColor];
			if(self.worker.isActive) {
				status = @"ACTIVE";
				backgroundColor = [UIColor yellowColor];
				textColor = [UIColor blackColor];
			} else if(self.worker.isReady) {
				status = @"READY";
				backgroundColor = [UIColor orangeColor];
				textColor = [UIColor blackColor];
			}
		}
        
        NSDictionary *userInfo = self.worker.userInfo;
        if(userInfo != nil) {
            UIColor *color = userInfo[@"backgroundColor"];
            if(color != nil) {
                backgroundColor = color;
            }
            color = userInfo[@"textColor"];
            if(color != nil) {
                textColor = color;
            }
        }
		
		self.label.textColor = textColor;
		self.layer.backgroundColor = backgroundColor.CGColor;
		self.layer.borderColor = [backgroundColor colorByDarkeningFraction:0.5].CGColor;
	
		CLogTrace(@"C_WORKER_DEBUG_VIEW", @"worker: %@ %@ isActive:%d", self.worker, status, self.worker.isActive);
	}
}

- (void)beginObserving
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncToWorker) name:@"workerViewNeedsSync" object:self];
	[self.worker addObserver:self forKeyPath:@"title" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isCancelled" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isReady" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isActive" options:0 context:nil];
	[self syncToWorker];
}

- (void)endObserving
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"workerViewNeedsSync" object:self];
	[self.worker removeObserver:self forKeyPath:@"title"];
	[self.worker removeObserver:self forKeyPath:@"isFinished"];
	[self.worker removeObserver:self forKeyPath:@"isCancelled"];
	[self.worker removeObserver:self forKeyPath:@"isReady"];
	[self.worker removeObserver:self forKeyPath:@"isActive"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

	if(object == self.worker) {
		CLogTrace(@"C_WORKER_DEBUG_VIEW", @"%@ observeValueForKeyPath:%@", self.worker, keyPath);
		[NSThread performBlockOnMainThread:^ {
			NSNotification* notification = [NSNotification notificationWithName:@"workerViewNeedsSync" object:self];
			[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
		}];
	}
}

- (CWorker*)worker
{
	return _worker;
}

- (void)setWorker:(CWorker *)worker
{
	if(_worker != worker) {
		[self endObserving];
		_worker = worker;
		if(_worker != nil) {
			[self beginObserving];
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.layer.cornerRadius = self.height / 2;
}

- (CGFloat)fontSize
{
	return self.label.font.pointSize;
}

- (void)setFontSize:(CGFloat)fontSize
{
	self.label.font = [UIFont boldSystemFontOfSize:fontSize];
}

- (CGFloat)minimumFontSize
{
	return self.label.minimumFontSize;
}

- (void)setMinimumFontSize:(CGFloat)minimumFontSize
{
	self.label.minimumFontSize = minimumFontSize;
}

@end
