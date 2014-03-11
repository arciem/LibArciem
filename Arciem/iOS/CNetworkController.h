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

#import "CNotifier.h"

@interface CNetworkController : NSObject

@property (copy, readonly, nonatomic) NSString* hostName;
@property (readonly, nonatomic) CNotifier* notifier;
@property (readonly, nonatomic) BOOL isReachable;
@property (nonatomic, setter = setOffline:) BOOL isOffline;

+ (CNetworkController*)sharedNetworkController;

- (void)startWithHostName:(NSString*)hostName networkReachabilityNotifierItem:(CNotifierItem*)networkReachabilityNotifierItem hostReachabilityNotifierItem:(CNotifierItem*)hostReachabilityNotifierItem networkReachableNotifierItem:(CNotifierItem*)networkReachableNotifierItem offlineNotifierItem:(CNotifierItem*)offlineNotifierItem;

- (void)toggleOffline;

@end
