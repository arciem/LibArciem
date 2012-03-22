/*******************************************************************************
 
 Copyright 2012 Arciem LLC
 
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

#import "CNetworkController.h"
#import "CReachability.h"

static CNetworkController* sSharedInstance = nil;

@interface CNetworkController ()

@property (copy, readwrite, nonatomic) NSString* hostName;
@property (strong, nonatomic) CReachability* networkReachability;
@property (strong, nonatomic) CReachability* hostReachability;
@property (strong, nonatomic) CNotifierItem* networkReachabilityNotifierItem;
@property (strong, nonatomic) CNotifierItem* hostReachabilityNotifierItem;
@property (strong, nonatomic) CNotifierItem* networkReachableNotifierItem;
@property (strong, nonatomic) CNotifierItem* offlineNotifierItem;
@property (strong, readwrite, nonatomic) CNotifier* notifier;
@property (readwrite, nonatomic) BOOL isReachable;

- (void)updateReachability;

@end

@implementation CNetworkController

@synthesize hostName = hostName_;
@synthesize networkReachability = networkReachability_;
@synthesize hostReachability = hostReachability_;
@synthesize networkReachabilityNotifierItem = networkReachabilityNotifierItem_;
@synthesize hostReachabilityNotifierItem = hostReachabilityNotifierItem_;
@synthesize networkReachableNotifierItem = networkReachableNotifierItem_;
@synthesize offlineNotifierItem = offlineNotifierItem_;
@synthesize notifier = notifier_;
@synthesize isReachable = isReachable_;
@dynamic isOffline;

+ (CNetworkController*)sharedInstance
{
	if(sSharedInstance == nil) {
		sSharedInstance = [[self alloc] init];
	}
	return sSharedInstance;
}

- (id)init
{
	if(self = [super init]) {
		self.notifier = [[CNotifier alloc] init];
		self.notifier.name = @"CNetworkController";

		self.networkReachability = [CReachability reachabilityForInternetConnection];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetReachabilityChanged:) name:kReachabilityChangedNotification object:self.networkReachability];
		[self.networkReachability startNotifier];
	}
	
	return self;
}

- (NSString*)hostName
{
	return hostName_;
}

- (void)setHostName:(NSString *)hostName
{
	NSAssert1(hostName_ == nil, @"hostName already set to %@", hostName_);
	hostName_ = hostName;
	self.hostReachability = [CReachability reachabilityWithHostName:hostName_];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostReachabilityChanged:) name:kReachabilityChangedNotification object:self.hostReachability];
	[self.hostReachability startNotifier];
}

- (void)startWithHostName:(NSString*)hostName networkReachabilityNotifierItem:(CNotifierItem*)networkReachabilityNotifierItem hostReachabilityNotifierItem:(CNotifierItem*)hostReachabilityNotifierItem networkReachableNotifierItem:(CNotifierItem*)networkReachableNotifierItem offlineNotifierItem:(CNotifierItem*)offlineNotifierItem
{
	self.hostName = hostName;
	self.networkReachabilityNotifierItem = networkReachabilityNotifierItem;
	self.hostReachabilityNotifierItem = hostReachabilityNotifierItem;
	self.networkReachableNotifierItem = networkReachableNotifierItem;
	self.offlineNotifierItem = offlineNotifierItem;
}

- (void)updateReachability
{
	static BOOL needReportReachable = NO;
	
	NetworkStatus networkReachability = self.networkReachability.currentReachabilityStatus;
	NetworkStatus hostReachability = self.hostReachability.currentReachabilityStatus;
	
	self.isReachable = networkReachability != NotReachable && hostReachability != NotReachable && !self.isOffline;
	
	if(self.isReachable) {
		// all clear
		[self.notifier removeItem:self.networkReachabilityNotifierItem];
		[self.notifier removeItem:self.hostReachabilityNotifierItem];
		[self.notifier removeItem:self.offlineNotifierItem];
		if(needReportReachable) {
			[self.notifier addItem:self.networkReachableNotifierItem];
			needReportReachable = NO;
		}
	} else {
		if(self.isOffline) {
			[self.notifier addItem:self.offlineNotifierItem];
			needReportReachable = YES;
		} else {
			[self.notifier removeItem:self.offlineNotifierItem];
		}

		if(networkReachability == NotReachable) {
			[self.notifier addItem:self.networkReachabilityNotifierItem];
			needReportReachable = YES;
		} else {
			[self.notifier removeItem:self.networkReachabilityNotifierItem];
		}
		
		if(hostReachability == NotReachable) {
			[self.notifier addItem:self.hostReachabilityNotifierItem];
			needReportReachable = YES;
		} else {
			[self.notifier removeItem:self.hostReachabilityNotifierItem];
		}
	}
}

- (void)internetReachabilityChanged:(NSNotification*)notification
{
	[self updateReachability];
}

- (void)hostReachabilityChanged:(NSNotification*)notification
{
	[self updateReachability];
}

+ (BOOL)automaticallyNotifiesObserversOfIsReachable
{
	return NO;
}

- (BOOL)isReachable
{
	return isReachable_;
}

- (void)setIsReachable:(BOOL)isReachable
{
	if(isReachable_ != isReachable) {
		[self willChangeValueForKey:@"isReachable"];
		isReachable_ = isReachable;
		[self didChangeValueForKey:@"isReachable"];
	}
}

+ (BOOL)automaticallyNotifiesObserversOfIsOffline
{
	return NO;
}

- (BOOL)isOffline
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"isOffline"];
}

- (void)setOffline:(BOOL)isOffline
{
	if(self.isOffline != isOffline) {
		[self willChangeValueForKey:@"isOffline"];
		[[NSUserDefaults standardUserDefaults] setBool:isOffline forKey:@"isOffline"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self updateReachability];
		[self didChangeValueForKey:@"isOffline"];
	}
}

- (void)toggleOffline
{
	self.isOffline = !self.isOffline;
}

@end
