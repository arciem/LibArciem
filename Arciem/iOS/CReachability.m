#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@import CoreFoundation;

#import "CReachability.h"

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
    CLogDebug(@"REACHABILITY_FLAGS", @"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
			(flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
			(flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
			
			(flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
			(flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
			(flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
			(flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
			comment
			);
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [CReachability class]], @"info was wrong class in ReachabilityCallback");
	
	//We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
	// in case someone uses the Reachablity object in a different thread.
	@autoreleasepool {
		CReachability* noteObject = (__bridge CReachability*) info;
		// Post a notification to notify the client that the network reachability changed.
		[[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification object:noteObject];
	}
}

@interface CReachability ()

@property (nonatomic) BOOL localWiFiRef;
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;

@end

@implementation CReachability

@synthesize localWiFiRef = localWiFiRef_;
@synthesize reachabilityRef = reachabilityRef_;

- (BOOL)startNotifier
{
	BOOL retVal = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context)) {
		if(SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
			retVal = YES;
		}
	}
	return retVal;
}

- (void)stopNotifier
{
	if(self.reachabilityRef != NULL) {
		SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}

- (void)dealloc
{
	[self stopNotifier];
	if(self.reachabilityRef != NULL) {
		CFRelease(self.reachabilityRef);
	}
}

+ (CReachability*)reachabilityWithHostName: (NSString*) hostName
{
	CReachability* retVal = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if(reachability != NULL) {
		retVal = [self new];
		if(retVal != NULL) {
			retVal.reachabilityRef = reachability;
			retVal.localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (CReachability*)reachabilityWithAddress: (const struct sockaddr_in*) hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
	CReachability* retVal = NULL;
	if(reachability != NULL) {
		retVal = [self new];
		if(retVal != NULL) {
			retVal.reachabilityRef = reachability;
			retVal.localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (CReachability*)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	return [self reachabilityWithAddress:&zeroAddress];
}

+ (CReachability*)reachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	CReachability* retVal = [self reachabilityWithAddress: &localWifiAddress];
	if(retVal!= NULL) {
		retVal.localWiFiRef = YES;
	}
	return retVal;
}

#pragma mark Network Flag Handling

- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "localWiFiStatusForFlags");

	NetworkStatus retVal = NetworkStatusNotReachable;
	if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
		retVal = NetworkStatusReachableViaWiFi;	
	}
	return retVal;
}

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "networkStatusForFlags");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// if target host is not reachable
		return NetworkStatusNotReachable;
	}

	NetworkStatus retVal = NetworkStatusNotReachable;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = NetworkStatusReachableViaWiFi;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
		(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
			// ... and the connection is on-demand (or on-traffic) if the
			//     calling application is using the CFSocketStream or higher APIs

			if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
				// ... and no [user] intervention is needed
				retVal = NetworkStatusReachableViaWiFi;
			}
		}
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = ReachableViaWWAN;
	}
	return retVal;
}

- (BOOL)connectionRequired
{
	NSAssert(self.reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
	return NO;
}

- (NetworkStatus)currentReachabilityStatus
{
	NSAssert(self.reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
	NetworkStatus retVal = NetworkStatusNotReachable;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
		if(self.localWiFiRef) {
			retVal = [self localWiFiStatusForFlags:flags];
		} else {
			retVal = [self networkStatusForFlags:flags];
		}
	}
	return retVal;
}
@end
