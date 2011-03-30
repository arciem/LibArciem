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

#import "PropertyUtils.h"

/*
 *
 * Checks if the property references an object.
 * In ObjC runtime property attribute strings that have 2nd char '@' are objects
 *
 */

BOOL IsPropertyAnObject(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    if (strlen(attributes)<2) {
        return NO;
    }
    return attributes[1] == '@';
}

BOOL IsPropertyAWritableObject(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    if (strlen(attributes)<4) {
        return NO;
    }
	if(attributes[1] == '@') {
		if(strstr(attributes, ",R") == NULL) {
			return YES;
		} else {
//			CLogDebug(nil, @"#### nonwritable:%s", attributes);
		}
	}
	return NO;
}

Class PropertyStaticType(objc_property_t property) {
    const char *attrs = property_getAttributes(property);
	NSString *attrString = [NSString stringWithUTF8String:attrs];
	
	//First " char
	NSRange r = [attrString rangeOfString:@"\""];
	
	if (r.location!=2 || r.location+1>=attrString.length) {
		return nil;
	}
	attrString = [attrString substringFromIndex:r.location+1];
	
	r = [attrString rangeOfString:@"\""];
	if (r.location!=NSNotFound) {
		attrString = [attrString substringToIndex:r.location];
	}
	
	return NSClassFromString(attrString);
}
