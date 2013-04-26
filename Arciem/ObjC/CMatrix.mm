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

#import "CMatrix.h"

@interface CMatrix ()

@property(nonatomic, retain) NSMutableArray* rows;
@property(nonatomic, readwrite) NSUInteger columnCount;

@end

@implementation CMatrix

@synthesize rows = rows_;
@synthesize columnCount = columnCount_;

@dynamic rowCount;

- (void)reset
{
	self.rows = [NSMutableArray array];
	self.columnCount = 0;
}

- (id)init
{
	if(self = [super init]) {
		[self reset];
	}
	
	return self;
}

+ (CMatrix*)matrix
{
	return [[self alloc] init];
}

- (NSUInteger)rowCount
{
	return self.rows.count;
}

- (id<NSObject>)objectAtIndexPath:(NSIndexPath*)path
{
	id<NSObject> item = nil;
	
	if(path.row < self.rows.count) {
		NSMutableArray* rowItems = (self.rows)[path.row];
		if(path.column < rowItems.count) {
			item = rowItems[path.column];
			if(item == [NSNull null]) {
				item = nil;
			}
		}
	}
	
	return item;
}

- (void)setObject:(id<NSObject>)obj atIndexPath:(NSIndexPath*)path
{
	while(path.row >= self.rows.count) {
		[self.rows addObject:[NSMutableArray array]];
	}
	
	NSMutableArray* rowItems = (self.rows)[path.row];
	
	while(path.column >= rowItems.count) {
		[rowItems addObject:[NSNull null]];
		if(rowItems.count > self.columnCount) {
			self.columnCount = rowItems.count;
		}
	}
	
	if(obj == nil) {
		obj = [NSNull null];
	}
	
	rowItems[path.column] = obj;
}

- (void)removeObjectAtIndexPath:(NSIndexPath*)path
{
	[self setObject:[NSNull null] atIndexPath:path];
}

- (void)removeAllObjects
{
	[self reset];
}

- (void)compact
{
	NSNull* nullObj = [NSNull null];
	NSInteger rowCount = self.rows.count;
	BOOL removeRowsEnabled = YES;
	self.columnCount = 0;
	
	for(NSInteger rowIndex = rowCount - 1; rowIndex >= 0; rowIndex--) {
		NSMutableArray* rowItems = (self.rows)[rowIndex];

		NSInteger columnCount = rowItems.count;
		for(NSInteger columnIndex = columnCount - 1; columnIndex >= 0; columnIndex--) {
			if(rowItems[columnIndex] == nullObj) {
				[rowItems removeLastObject];
			} else {
				break;
			}
		}
		
		if(rowItems.count > self.columnCount) {
			self.columnCount = rowItems.count;
		}
		
		if(removeRowsEnabled) {
			if(rowItems.count == 0) {
				[self.rows removeLastObject];
			} else {
				removeRowsEnabled = NO;
			}
		}
	}
}

@end
