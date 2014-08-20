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

@import QuartzCore;
#import "CWorkerDebugView.h"
#import "UIViewUtils.h"
#import "ThreadUtils.h"
#import "UIColorUtils.h"
#import "DispatchUtils.h"

static const CGFloat kCWorkerDebugViewFontSize = 14;
static const CGFloat kCWorkerDebugViewMinimumScaleFactor = 0.4;

@interface CWorkerDebugView ()

@property (nonatomic) UILabel* label;
@property (nonatomic) CLayoutConstraintsGroup *myConstraintsGroup;

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

- (instancetype)initWithFrame:(CGRect)frame worker:(CWorker*)worker
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
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
	
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
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
	self.label.backgroundColor = [UIColor clearColor];
	self.label.opaque = NO;
//	self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.fontSize = kCWorkerDebugViewFontSize;
//	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.adjustsFontSizeToFitWidth = YES;
	self.label.minimumScaleFactor = kCWorkerDebugViewMinimumScaleFactor;
	self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:self.label];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    self.myConstraintsGroup = [CLayoutConstraintsGroup groupWithOwner:self];
    [self.myConstraintsGroup addConstraint:[self.label constrainTopEqualToTopOfItem:self]];
    [self.myConstraintsGroup addConstraint:[self.label constrainBottomEqualToBottomOfItem:self]];
    [self.myConstraintsGroup addConstraint:[self.label constrainLeadingGreaterThanOrEqualToLeadingOfItem:self offset:10]];
    [self.myConstraintsGroup addConstraint:[self.label constrainTrailingLessThanOrEqualToTrailingOfItem:self offset:-10]];
    [self.myConstraintsGroup addConstraint:[self.label constrainCenterXEqualToCenterXOfItem:self]];
}

- (void)syncToWorker
{
    self.label.text = self.worker.title;
#if DEBUG
    NSString* status = @"UNKNOWN";
#endif
    UIColor* backgroundColor = [UIColor grayColor];
    UIColor* textColor = [UIColor whiteColor];
    
    if(self.worker.finished) {
#if DEBUG
        status = @"FINISHED";
#endif
        if(self.worker.error == nil) {
            backgroundColor = [[UIColor greenColor] newColorByDarkeningFraction:0.7];
        } else {
            backgroundColor = [[UIColor redColor] newColorByDarkeningFraction:0.5];
        }
        textColor = [UIColor whiteColor];
        if(self.worker.cancelled) {
#if DEBUG
            status = @"CANCELLED";
#endif
            backgroundColor = [UIColor blackColor];
            textColor = [UIColor whiteColor];
        }
    } else if(self.worker.executing) {
#if DEBUG
        status = @"EXECUTING";
#endif
        backgroundColor = [[UIColor blueColor] newColorByLighteningFraction:0.5];
        textColor = [UIColor blackColor];
        if(self.worker.active) {
#if DEBUG
            status = @"ACTIVE";
#endif
            backgroundColor = [UIColor yellowColor];
            textColor = [UIColor blackColor];
        } else if(self.worker.ready) {
#if DEBUG
            status = @"READY";
#endif
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
    self.layer.borderColor = [backgroundColor newColorByDarkeningFraction:0.5].CGColor;
    
    CLogTrace(@"C_WORKER_DEBUG_VIEW", @"worker: %@ %@ active:%d", self.worker, status, self.worker.active);
    
    [self setNeedsUpdateConstraints];
}

- (void)beginObserving
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncToWorker) name:@"workerViewNeedsSync" object:self];
	[self.worker addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptions)0 context:nil];
	[self.worker addObserver:self forKeyPath:@"finished" options:(NSKeyValueObservingOptions)0 context:nil];
	[self.worker addObserver:self forKeyPath:@"cancelled" options:(NSKeyValueObservingOptions)0 context:nil];
	[self.worker addObserver:self forKeyPath:@"ready" options:(NSKeyValueObservingOptions)0 context:nil];
	[self.worker addObserver:self forKeyPath:@"active" options:(NSKeyValueObservingOptions)0 context:nil];
	[self syncToWorker];
}

- (void)endObserving
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"workerViewNeedsSync" object:self];
	[self.worker removeObserver:self forKeyPath:@"title"];
	[self.worker removeObserver:self forKeyPath:@"finished"];
	[self.worker removeObserver:self forKeyPath:@"cancelled"];
	[self.worker removeObserver:self forKeyPath:@"ready"];
	[self.worker removeObserver:self forKeyPath:@"active"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

	if(object == self.worker) {
		CLogTrace(@"C_WORKER_DEBUG_VIEW", @"%@ observeValueForKeyPath:%@", self.worker, keyPath);
		dispatchOnMain(^{
			NSNotification* notification = [NSNotification notificationWithName:@"workerViewNeedsSync" object:self];
			[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
		});
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

- (CGFloat)minimumScaleFactor
{
	return self.label.minimumScaleFactor;
}

- (void)setMinimumScaleFactor:(CGFloat)minimumScaleFactor
{
	self.label.minimumScaleFactor = minimumScaleFactor;
}

@end
