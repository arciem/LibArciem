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

#import "CMutableArray.h"

@interface CMutableArray ()

@property (strong, nonatomic) NSMutableArray* objects;
@property (weak, nonatomic) id owner;
@property (copy, nonatomic) NSString* key;

@end

@implementation CMutableArray

@synthesize objects = objects_;
@synthesize owner = owner_;
@synthesize key = key_;

- (id)initWithOwner:(id)owner key:(NSString*)key
{
	if(self = [super init]) {
		self.objects = [NSMutableArray array];
		self.owner = owner;
		self.key = key;
	}
	return self;
}

+ (id)arrayWithOwner:(id)owner key:(NSString*)key
{
	return [[[self class] alloc] initWithOwner:owner key:key];
}

#pragma mark - Primitive NSArray overrides

- (NSUInteger)count
{
	return self.objects.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
	return [self.objects objectAtIndex:index];
}

#pragma mark - Primitive NSMutableArray overrides

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
	[self.owner willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
	[self.objects insertObjects:objects atIndexes:indexes];
	[self.owner didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.key];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
	NSArray* objects = [NSArray arrayWithObject:anObject];
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:index];
	[self insertObjects:objects atIndexes:indexes];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
	[self.owner willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
	[self.objects removeObjectsAtIndexes:indexes];
	[self.owner didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.key];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:index];
	[self removeObjectsAtIndexes:indexes];
}

- (void)addObject:(id)anObject
{
	[self insertObject:anObject atIndex:self.count];
}

- (void)removeLastObject
{
	[self removeObjectAtIndex:self.count];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
	[self.owner willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
	[self.objects replaceObjectsAtIndexes:indexes withObjects:objects];
	[self.owner didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:self.key];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	NSArray* objects = [NSArray arrayWithObject:anObject];
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:index];
	[self replaceObjectsAtIndexes:indexes withObjects:objects];
}

@end
