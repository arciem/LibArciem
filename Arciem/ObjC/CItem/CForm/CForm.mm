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

- (instancetype)initWithRootItem:(CItem*)rootItem
{
	if(self = [super init]) {
		self.rootItem = rootItem;
	}
	return self;
}

+ (CForm*)newFormWithRootItem:(CItem *)rootItem
{
	return [[self alloc] initWithRootItem:rootItem];
}

+ (CForm*)newFormForResourceName:(NSString*)resourceName withExtension:(NSString*)extension
{
	NSURL* url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:extension];
	NSData* data = [NSData dataWithContentsOfURL:url];
	NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	CItem* item = [CItem newItemWithJSONRepresentation:json];
	CForm* form = [self newFormWithRootItem:item];
	return form;
}

+ (CForm*)newFormForResourceName:(NSString*)resourceName
{
	return [self newFormForResourceName:resourceName withExtension:@"json"];
}

- (void)dealloc
{
	self.rootItem = nil;
}

@end
