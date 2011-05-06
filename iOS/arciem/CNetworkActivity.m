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

@interface CNetworkActivity ()

@property(nonatomic, readwrite) NSUInteger sequenceNumber;
@property(nonatomic, readwrite, getter = hasIndicator) BOOL indicator;
@property(nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@end

static NSUInteger sNextSequenceNumber = 1;


@interface CNetworkActivityIndicator : NSObject

@property(nonatomic, retain) NSTimer* timer;
@property(nonatomic) NSInteger activationsCount;

+ (CNetworkActivityIndicator*)sharedIndicator;
- (void)addActivity;
- (void)removeActivity;

@end

static const NSTimeInterval kTimerInterval = 0.1;
static const NSTimeInterval kIndicatorHysteresisInterval = 0.2;
static CNetworkActivityIndicator* sSharedIndicator = nil;
static NSMutableArray* sActivities = nil;
static NSTimeInterval sLastRemoveTime = 0;


@implementation CNetworkActivity

@synthesize sequenceNumber = sequenceNumber_;
@synthesize name = name_;
@synthesize indicator = indicator_;
@synthesize backgroundTaskIdentifier = backgroundTaskIdentifier_;

- (id)initWithIndicator:(BOOL)indicator
{
	@synchronized([self class]) {
		if((self = [super init])) {
			CLogDebug(@"NETWORK_ACTIVITY", @"%@ init:%d", self, [self retainCount]);
			self.sequenceNumber = sNextSequenceNumber++;
			self.indicator = indicator;
			if(sActivities == nil) {
				sActivities = [[NSMutableArray alloc] init];
			}
			[sActivities addObject:[NSValue valueWithNonretainedObject:self]];
			if(self.hasIndicator) {
				[[CNetworkActivityIndicator sharedIndicator] addActivity];
			}
			UIApplication* app = [UIApplication sharedApplication];
			// avoid retain cycle on self
			NSValue* val = [NSValue valueWithNonretainedObject:self];
			self.backgroundTaskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{
				CNetworkActivity* s = (CNetworkActivity*)[val nonretainedObjectValue];
				[app endBackgroundTask:s.backgroundTaskIdentifier];
				s.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
			}];
		}
	}
	
	return self;
}

- (id)init
{
	return [self initWithIndicator:NO];
}

- (id)retain
{
	CLogDebug(@"NETWORK_ACTIVITY", @"%@ retain:%d", self, [self retainCount] + 1);
	return [super retain];
}

- (void)release
{
	CLogDebug(@"NETWORK_ACTIVITY", @"%@ release:%d", self, [self retainCount] - 1);
	[super release];
}

- (void)dealloc
{
	@synchronized([self class]) {
		CLogDebug(@"NETWORK_ACTIVITY", @"%@ dealloc", self);
		for(NSValue* v in sActivities) {
			if([v nonretainedObjectValue] == self) {
				[sActivities removeObject:v];
				sLastRemoveTime = [NSDate timeIntervalSinceReferenceDate];
				if(self.hasIndicator) {
					[[CNetworkActivityIndicator sharedIndicator] removeActivity];
				}
				break;
			}
		}
	}

	[super dealloc];
}

+ (CNetworkActivity*)activityWithIndicator:(BOOL)indicator
{
	return [[[CNetworkActivity alloc] initWithIndicator:indicator] autorelease];
}

@end


@implementation CNetworkActivityIndicator

@synthesize timer = timer_;
@synthesize activationsCount = activationsCount_;

- (id)init
{
	if((self = [super init])) {
		self.timer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
	}
	
	return self;
}

+ (CNetworkActivityIndicator*)sharedIndicator
{
	if(sSharedIndicator == nil) {
		sSharedIndicator = [[CNetworkActivityIndicator alloc] init];
	}
	
	return sSharedIndicator;
}

- (void)turnOnIndicator
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)turnOffIndicator
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)timerFired:(NSTimer*)timer
{
	@synchronized(self) {
		if(self.activationsCount == 0) {
			if([NSDate timeIntervalSinceReferenceDate] - sLastRemoveTime > kIndicatorHysteresisInterval) {
				[self turnOffIndicator];
			}
		} else {
			[self turnOnIndicator];
		}
	}
}

- (void)addActivity
{
	@synchronized(self) {
		self.activationsCount++;
		CLogDebug(@"NETWORK_ACTIVITY", @"%@ addActivity: %d", self, self.activationsCount);
	}
}

- (void)removeActivity
{
	@synchronized(self) {
		self.activationsCount--;
		CLogDebug(@"NETWORK_ACTIVITY", @"%@ removeActivity: %d", self, self.activationsCount);
	}
}

@end
