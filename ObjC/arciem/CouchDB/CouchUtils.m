//
//  CouchUtils.m
//  FitOrbit
//
//  Created by Robert McNally on 5/5/11.
//  Copyright 2011 FitOrbit. All rights reserved.
//

#import "CouchUtils.h"

void CouchCheckDatabaseName(NSString* databaseName)
{
	static NSRegularExpression* regex = nil;
	if(regex == nil) {
		regex = [[NSRegularExpression alloc] initWithPattern:@"^[a-z][a-z0-9()_$+-]*$" options:0 error:nil];
	}
	BOOL valid = [regex numberOfMatchesInString:databaseName options:regex.options range:NSMakeRange(0, databaseName.length)] == 1;
	NSCAssert1(valid, @"Invalid database name: %@", databaseName);
}
