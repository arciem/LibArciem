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

#import "CNetworkActivity.h"
#import "CLog.h"
#import "ObjectUtils.h"
#import "ThreadUtils.h"

@class CNetworkActivityIndicator;

static NSUInteger sNextSequenceNumber = 1;
static const NSTimeInterval kTimerInterval = 0.1;
static const NSTimeInterval kIndicatorHysteresisInterval = 0.2;
static NSTimeInterval sLastRemoveTime = 0;

@interface CNetworkActivity ()

@property(nonatomic, readwrite) NSUInteger sequenceNumber;
@property(nonatomic, readwrite, getter = hasIndicator) BOOL indicator;
@property(nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@interface CNetworkActivityIndicator : NSObject

@property (nonatomic) NSTimer* timer;
@property (nonatomic) NSInteger activationsCount;
@property(readonly, nonatomic) NSOperationQueue *queue;

+ (CNetworkActivityIndicator*)sharedIndicator;
- (void)addActivity;
- (void)removeActivity;

@end

@implementation CNetworkActivity

- (NSString*)description
{
	return [self formatObjectWithValues:@[[self formatValueForKey:@"sequenceNumber" compact:YES],
										 [self formatBoolValueForKey:@"hasIndicator" compact:YES]]];
}

- (instancetype)initWithIndicator:(BOOL)indicator
{
    if(self = [super init]) {
        self.sequenceNumber = sNextSequenceNumber++;
        self.indicator = indicator;
        CLogDebug(@"NETWORK_ACTIVITY", @"%@ init", self);
        if(self.hasIndicator) {
            [[CNetworkActivityIndicator sharedIndicator] addActivity];
        }
        BSELF;
        __block UIBackgroundTaskIdentifier taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
            taskIdentifier = UIBackgroundTaskInvalid;
            bself.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];
        self.backgroundTaskIdentifier = taskIdentifier;
    }
	
	return self;
}

- (instancetype)init
{
	return [self initWithIndicator:NO];
}

- (void)dealloc
{
    CLogDebug(@"NETWORK_ACTIVITY", @"%@ dealloc", self);
    sLastRemoveTime = [NSDate timeIntervalSinceReferenceDate];
    if(self.hasIndicator) {
        [[CNetworkActivityIndicator sharedIndicator] removeActivity];
    }
    if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

+ (CNetworkActivity*)activityWithIndicator:(BOOL)indicator
{
	return [[CNetworkActivity alloc] initWithIndicator:indicator];
}

@end


@implementation CNetworkActivityIndicator

@synthesize timer = timer_;
@synthesize activationsCount = activationsCount_;

- (NSOperationQueue *)queue {
    static NSOperationQueue *q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = [NSOperationQueue new];
    });
    
    return q;
}

- (instancetype)init
{
	if((self = [super init])) {
		self.timer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
	}
	
	return self;
}

+ (CNetworkActivityIndicator*)sharedIndicator
{
    static CNetworkActivityIndicator *indicator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        indicator = [CNetworkActivityIndicator new];
    });
	
	return indicator;
}

- (void)turnOnIndicator
{
#if TESTING
    BSELF;
#endif
    [self.queue performSynchronousOperationWithBlock:^{
        UIApplication *app = [UIApplication sharedApplication];
        if(!app.networkActivityIndicatorVisible) {
            CLogDebug(@"NETWORK_ACTIVITY", @"%@ turnOnIndicator", bself);
            app.networkActivityIndicatorVisible = YES;
        }
    }];
}

- (void)turnOffIndicator
{
#if TESTING
    BSELF;
#endif
    [self.queue performSynchronousOperationWithBlock:^{
        UIApplication *app = [UIApplication sharedApplication];
        if(app.networkActivityIndicatorVisible) {
            CLogDebug(@"NETWORK_ACTIVITY", @"%@ turnOffIndicator", bself);
            app.networkActivityIndicatorVisible = NO;
        }
    }];
}

- (void)timerFired:(NSTimer*)timer
{
    BSELF;
    [self.queue performSynchronousOperationWithBlock:^{
//		CLogDebug(@"NETWORK_ACTIVITY", @"%@ timerFired activationsCount:%d", bself, bself.activationsCount);
		if(bself.activationsCount == 0) {
			if([NSDate timeIntervalSinceReferenceDate] - sLastRemoveTime > kIndicatorHysteresisInterval) {
				[bself turnOffIndicator];
			}
		}
	}];
}

- (void)addActivity
{
    BSELF;
    [self.queue performSynchronousOperationWithBlock:^{
		bself.activationsCount++;
        if(bself.activationsCount == 1) {
            [bself turnOnIndicator];
        }
		CLogDebug(@"NETWORK_ACTIVITY", @"%@ addActivity activationsCount:%d", bself, bself.activationsCount);
	}];
}

- (void)removeActivity
{
    BSELF;
    [self.queue performSynchronousOperationWithBlock:^{
		bself.activationsCount--;
		CLogDebug(@"NETWORK_ACTIVITY", @"%@ removeActivity activationsCount:%d", bself, bself.activationsCount);
	}];
}

@end
