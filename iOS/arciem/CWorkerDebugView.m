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

#import "CWorkerDebugView.h"
#import "UIViewUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "ThreadUtils.h"
#import "UIColorUtils.h"

@interface CWorkerDebugView ()

//@property (strong, readwrite, nonatomic) CWorker* worker;
@property (strong, nonatomic) UILabel* label;

@end

@implementation CWorkerDebugView

@synthesize worker = worker_;
@synthesize state = state_;
@synthesize label = label_;
@synthesize position = position_;

+ (void)initialize
{
//	CLogSetTagActive(@"C_WORKER_DEBUG_VIEW", YES);
}

- (id)initWithWorker:(CWorker*)worker;
{
	if(self = [super initWithFrame:CGRectZero]) {
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
	self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	self.layer.masksToBounds = YES;
	self.layer.cornerRadius = 10.0;
	self.layer.borderWidth = 1.0;
	
	self.label = [[UILabel alloc] initWithFrame:self.bounds];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.opaque = NO;
	self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.label.font = [UIFont boldSystemFontOfSize:14.0];
	self.label.textAlignment = UITextAlignmentCenter;
	[self addSubview:self.label];

	self.state = CRestWorkerViewNew;
}

- (void)syncToWorker
{
	@synchronized(self.worker) {
		self.label.text = self.worker.identifier;
		NSString* status = @"UNKNOWN";
		UIColor* backgroundColor = [UIColor grayColor];
		UIColor* textColor = [UIColor whiteColor];
		
		if(self.worker.isFinished) {
			status = @"FINISHED";
			backgroundColor = [UIColor blueColor];
			textColor = [UIColor whiteColor];
			if(self.worker.isCancelled) {
				status = @"CANCELLED";
				backgroundColor = [UIColor blackColor];
				textColor = [UIColor whiteColor];
			}
		} else if(self.worker.isExecuting) {
			status = @"EXECUTING";
			backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
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
		
		self.label.textColor = textColor;
		self.layer.backgroundColor = backgroundColor.CGColor;
		self.layer.borderColor = [backgroundColor colorByDarkeningFraction:0.5].CGColor;
	
		CLogTrace(@"C_WORKER_DEBUG_VIEW", @"worker: %@ %@ isActive:%d", self.worker, status, self.worker.isActive);
	}
}

- (void)beginObserving
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncToWorker) name:@"workerViewNeedsSync" object:self];
	[self.worker addObserver:self forKeyPath:@"identifier" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isCancelled" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isReady" options:0 context:nil];
	[self.worker addObserver:self forKeyPath:@"isActive" options:0 context:nil];
	[self syncToWorker];
}

- (void)endObserving
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"workerViewNeedsSync" object:self];
	[self.worker removeObserver:self forKeyPath:@"identifier"];
	[self.worker removeObserver:self forKeyPath:@"isFinished"];
	[self.worker removeObserver:self forKeyPath:@"isCancelled"];
	[self.worker removeObserver:self forKeyPath:@"isReady"];
	[self.worker removeObserver:self forKeyPath:@"isActive"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self.worker) {
		CLogTrace(@"C_WORKER_DEBUG_VIEW", @"%@ observeValueForKeyPath:%@", self.worker, keyPath);
		[NSThread performBlockOnMainThread:^ {
			NSNotification* notification = [NSNotification notificationWithName:@"workerViewNeedsSync" object:self];
			[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:nil];
		}];
	}
}

- (CWorker*)worker
{
	return worker_;
}

- (void)setWorker:(CWorker *)worker
{
	if(worker_ != worker) {
		[self endObserving];
		worker_ = worker;
		if(worker_ != nil) {
			[self beginObserving];
		}
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(200, 20);
}

@end
