//
//  CKeychainUtils.mm
//  Arciem
//
//  Based on:
//
// SFHFKeychainUtils.m
//
// Created by Buzz Andersen on 10/20/08.
// Based partly on code by Jonathan Wight, Jon Crosby, and Mike Malone.
// Copyright 2008 Sci-Fi Hi-Fi. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "CKeychainUtils.h"
#import <Security/Security.h>

static NSString* const CKeychainUtilsErrorDomain = @"CKeychainUtilsErrorDomain";

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000 && TARGET_IPHONE_SIMULATOR
@interface CKeychainUtils (PrivateMethods)
+ (SecKeychainItemRef) getKeychainItemReferenceForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;
@end
#endif

@implementation CKeychainUtils

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000 && TARGET_IPHONE_SIMULATOR

+ (NSString *) getPasswordForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return nil;
	}
	
	SecKeychainItemRef item = [CKeychainUtils getKeychainItemReferenceForUsername: username andServiceName: serviceName error: error];
	
	if (*error || !item) {
		return nil;
	}
	
	// from Advanced Mac OS X Programming, ch. 16
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    OSStatus status = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&password);
	
	if (status != noErr) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
		return nil;
    }
    
	NSString *passwordString = nil;
	
	if (password != NULL) {
		char passwordBuffer[1024];
		
		if (length > 1023) {
			length = 1023;
		}
		strncpy(passwordBuffer, password, length);
		
		passwordBuffer[length] = '\0';
		passwordString = [NSString stringWithCString:passwordBuffer];
	}
	
	SecKeychainItemFreeContent(&list, password);
    
    CFRelease(item);
    
    return passwordString;
}

+ (void) storeUsername: (NSString *) username andPassword: (NSString *) password forServiceName: (NSString *) serviceName updateExisting: (BOOL) updateExisting error: (NSError **) error {
	if (!username || !password || !serviceName) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return;
	}
	
	OSStatus status = noErr;
	
	SecKeychainItemRef item = [CKeychainUtils getKeychainItemReferenceForUsername: username andServiceName: serviceName error: error];
	
	if (*error && [*error code] != noErr) {
		return;
	}
	
	*error = nil;
	
	if (item) {
		status = SecKeychainItemModifyAttributesAndData(item,
														NULL,
														strlen([password UTF8String]),
														[password UTF8String]);
		
		CFRelease(item);
	}
	else {
		status = SecKeychainAddGenericPassword(NULL,
											   strlen([serviceName UTF8String]),
											   [serviceName UTF8String],
											   strlen([username UTF8String]),
											   [username UTF8String],
											   strlen([password UTF8String]),
											   [password UTF8String],
											   NULL);
	}
	
	if (status != noErr) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
	}
}

+ (void) deleteItemForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: 2000 userInfo: nil];
		return;
	}
	
	*error = nil;
	
	SecKeychainItemRef item = [CKeychainUtils getKeychainItemReferenceForUsername: username andServiceName: serviceName error: error];
	
	if (*error && [*error code] != noErr) {
		return;
	}
	
	OSStatus status;
	
	if (item) {
		status = SecKeychainItemDelete(item);
		
		CFRelease(item);
	}
	
	if (status != noErr) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
	}
}

+ (SecKeychainItemRef) getKeychainItemReferenceForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
		*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return nil;
	}
	
	*error = nil;
    
	SecKeychainItemRef item;
	
	OSStatus status = SecKeychainFindGenericPassword(NULL,
													 strlen([serviceName UTF8String]),
													 [serviceName UTF8String],
													 strlen([username UTF8String]),
													 [username UTF8String],
													 NULL,
													 NULL,
													 &item);
	
	if (status != noErr) {
		if (status != errSecItemNotFound) {
			*error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
		}
		
		return nil;
	}
	
	return item;
}

#else

+ (NSString *) getPasswordForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
        if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return nil;
	}
    
	if (error) *error = nil;
    
	// Set up a query dictionary with the base query attributes: item type (generic), username, and service
	
	NSArray *keys = @[(__bridge NSString *) kSecClass, (__bridge id)kSecAttrAccount, (__bridge id)kSecAttrService];
	NSArray *objects = @[(__bridge NSString *) kSecClassGenericPassword, username, serviceName];
	
	NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys];
	
	// First do a query for attributes, in case we already have a Keychain item with no password data set.
	// One likely way such an incorrect item could have come about is due to the previous (incorrect)
	// version of this code (which set the password as a generic attribute instead of password data).
	
	NSDictionary *attributeResult = NULL;
	NSMutableDictionary *attributeQuery = [query mutableCopy];
	attributeQuery[(__bridge id) kSecReturnAttributes] = (id) kCFBooleanTrue;
	CFTypeRef attributeResultRef;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) attributeQuery, &attributeResultRef);
	if(status == noErr) {
		attributeResult = CFBridgingRelease(attributeResultRef);
	}
	
	if (status != noErr) {
		// No existing item found--simply return nil for the password
		if (status != errSecItemNotFound) {
			//Only return an error if a real exception happened--not simply for "not found."
			if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
		}
		
		return nil;
	}
	
	// We have an existing item, now query for the password data associated with it.
	
	NSData *resultData = nil;
	NSMutableDictionary *passwordQuery = [query mutableCopy];
	passwordQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;
    
	CFTypeRef resultDataRef;
	status = SecItemCopyMatching((__bridge CFDictionaryRef) passwordQuery, &resultDataRef);
	if(status == noErr) {
		resultData = CFBridgingRelease(resultDataRef);
	}
	
	if (status != noErr) {
		if (status == errSecItemNotFound) {
			// We found attributes for the item previously, but no password now, so return a special error.
			// Users of this API will probably want to detect this error and prompt the user to
			// re-enter their credentials. When you attempt to store the re-entered credentials
			// using storeUsername:andPassword:forServiceName:updateExisting:error
			// the old, incorrect entry will be deleted and a new one with a properly encrypted
			// password will be added.
			if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -1999 userInfo: nil];
		}
		else {
			// Something else went wrong. Simply return the normal Keychain API error code.
			if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
		}
		
		return nil;
	}
    
	NSString *password = nil;
    
	if (resultData) {
		password = [[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding];
	}
	else {
		// There is an existing item, but we weren't able to get password data for it for some reason,
		// Possibly as a result of an item being incorrectly entered by the previous code.
		// Set the -1999 error so the code above us can prompt the user again.
		if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -1999 userInfo: nil];
	}
    
	return password;
}

+ (BOOL) storeUsername: (NSString *) username andPassword: (NSString *) password forServiceName: (NSString *) serviceName updateExisting: (BOOL) updateExisting error: (NSError **) error {
	if (!username || !password || !serviceName) {
		if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return NO;
	}
	
	// See if we already have a password entered for these credentials.
	NSError *checkPasswordError = nil;
	NSString *existingPassword = [CKeychainUtils getPasswordForUsername: username andServiceName: serviceName error: &checkPasswordError];
    
	if ([checkPasswordError code] == -1999) {
		// There is an existing entry without a password properly stored (possibly as a result of the previous incorrect version of this code.
		// Delete the existing item before moving on entering a correct one.
        
		NSError *deleteError = nil;
		
		[self deleteItemForUsername: username andServiceName: serviceName error: &deleteError];
        
		if ([deleteError code] != noErr) {
            if (error) *error = deleteError;
			return NO;
		}
	}
	else if ([checkPasswordError code] != noErr) {
        if (error) *error = checkPasswordError;
		return NO;
	}
	
	if (error) *error = nil;
	
	OSStatus status = noErr;
    
	if (existingPassword) {
		// We have an existing, properly entered item with a password.
		// Update the existing item.
		
		if (![existingPassword isEqualToString:password] && updateExisting) {
			//Only update if we're allowed to update existing. If not, simply do nothing.
			
			NSArray *keys = @[(__bridge NSString *) kSecClass,
                             (__bridge id)kSecAttrService,
                             (__bridge id)kSecAttrLabel,
                             (__bridge id)kSecAttrAccount];
			
			NSArray *objects = @[(__bridge NSString *) kSecClassGenericPassword,
                                serviceName,
                                serviceName,
                                username];
			
			NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
			
			status = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) @{(__bridge NSString *) kSecValueData: [password dataUsingEncoding: NSUTF8StringEncoding]});
		}
	}
	else {
		// No existing entry (or an existing, improperly entered, and therefore now
		// deleted, entry). Create a new entry.
		
		NSArray *keys = @[(__bridge NSString *) kSecClass,
                         (__bridge id)kSecAttrService,
                         (__bridge id)kSecAttrLabel,
                         (__bridge id)kSecAttrAccount,
                         (__bridge id)kSecValueData];
		
		NSArray *objects = @[(__bridge NSString *) kSecClassGenericPassword,
                            serviceName,
                            serviceName,
                            username,
                            [password dataUsingEncoding: NSUTF8StringEncoding]];
		
		NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
        
		status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
	}
	
	if (status != noErr) {
		// Something went wrong with adding the new item. Return the Keychain error code.
		if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
        return NO;
	}
    return YES;
}

+ (BOOL) deleteItemForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error {
	if (!username || !serviceName) {
		if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return NO;
	}
	
	if (error) *error = nil;
    
	NSArray *keys = @[(__bridge NSString *) kSecClass, (__bridge id)kSecAttrAccount, (__bridge id)kSecAttrService, (__bridge id)kSecReturnAttributes];
	NSArray *objects = @[(__bridge NSString *) kSecClassGenericPassword, username, serviceName, (id)kCFBooleanTrue];
	
	NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
	
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);
	
	if (status != noErr) {
		if (error) *error = [NSError errorWithDomain: CKeychainUtilsErrorDomain code: status userInfo: nil];
        return NO;
	}
    return YES;
}

#endif

@end