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

#import "CForm.h"

@implementation CForm

@synthesize rootItem = rootItem_;

- (CItem*)rootItem
{
	return rootItem_;
}

- (void)setRootItem:(CItem *)rootItem
{
	[rootItem_ deactivateAll];
	rootItem_ = rootItem;
	[rootItem_ activateAll];
}

- (id)initWithRootItem:(CItem*)rootItem
{
	if(self = [super init]) {
		self.rootItem = rootItem;
	}
	return self;
}

+ (CForm*)formWithRootItem:(CItem *)rootItem
{
	return [[[self class] alloc] initWithRootItem:rootItem];
}

+ (CForm*)formForResourceName:(NSString*)resourceName withExtension:(NSString*)extension
{
	NSURL* url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:extension];
	NSData* data = [NSData dataWithContentsOfURL:url];
	NSError* error = nil;
	NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSAssert1(error == nil, @"Error reading JSON:%@", error);
	CItem* item = [CItem itemWithDictionary:dict];
	CForm* form = [self formWithRootItem:item];
	return form;
}

- (void)dealloc
{
	self.rootItem = nil;
}


@end
