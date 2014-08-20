@import Foundation;
@import SystemConfiguration;
#import <netinet/in.h>

typedef NS_ENUM(NSInteger, NetworkStatus) {
	NetworkStatusNotReachable = 0,
	NetworkStatusReachableViaWiFi,
	ReachableViaWWAN
};

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface CReachability: NSObject

//reachabilityWithHostName- Use to check the reachability of a particular host name. 
+ (CReachability*)reachabilityWithHostName:(NSString*)hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address. 
+ (CReachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;

//reachabilityForInternetConnection- checks whether the default route is available.  
//  Should be used by applications that do not connect to a particular host
+ (CReachability*)reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
+ (CReachability*)reachabilityForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL)startNotifier;
- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;

//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL)connectionRequired;

@end
