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

@interface CNetworkController ()

@property (copy, readwrite, nonatomic) NSString* hostName;
@property (nonatomic) CReachability* networkReachability;
@property (nonatomic) CReachability* hostReachability;
@property (nonatomic) CNotifierItem* networkReachabilityNotifierItem;
@property (nonatomic) CNotifierItem* hostReachabilityNotifierItem;
@property (nonatomic) CNotifierItem* networkReachableNotifierItem;
@property (nonatomic) CNotifierItem* offlineNotifierItem;
@property (strong, readwrite, nonatomic) CNotifier* notifier;
@property (readwrite, nonatomic) BOOL isReachable;

@end

@implementation CNetworkController

@synthesize hostName = _hostName;
@synthesize isReachable = _isReachable;

+ (CNetworkController*)sharedNetworkController
{
    static CNetworkController* instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [CNetworkController new];
    });
    return instance;
}

- (instancetype)init
{
	if(self = [super init]) {
		self.notifier = [CNotifier new];
		self.notifier.name = @"CNetworkController";

		self.networkReachability = [CReachability reachabilityForInternetConnection];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetReachabilityChanged:) name:kReachabilityChangedNotification object:self.networkReachability];
		[self.networkReachability startNotifier];
	}
	
	return self;
}

- (NSString*)hostName
{
	return _hostName;
}

- (void)setHostName:(NSString *)hostName
{
	NSAssert1(_hostName == nil, @"hostName already set to %@", _hostName);
	_hostName = hostName;
	self.hostReachability = [CReachability reachabilityWithHostName:_hostName];
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
	
	self.isReachable = networkReachability != NetworkStatusNotReachable && hostReachability != NetworkStatusNotReachable && !self.isOffline;
	
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

		if(networkReachability == NetworkStatusNotReachable) {
			[self.notifier addItem:self.networkReachabilityNotifierItem];
			needReportReachable = YES;
		} else {
			[self.notifier removeItem:self.networkReachabilityNotifierItem];
		}
		
		if(hostReachability == NetworkStatusNotReachable) {
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
	return _isReachable;
}

- (void)setIsReachable:(BOOL)isReachable
{
	if(_isReachable != isReachable) {
		[self willChangeValueForKey:@"isReachable"];
		_isReachable = isReachable;
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
