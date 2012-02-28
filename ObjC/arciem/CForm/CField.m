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

#import "CField.h"
#import "ObjectUtils.h"
#import "ErrorUtils.h"

NSString* const CFieldErrorDomain = @"CFieldErrorDomain";

@interface CField ()

@property (strong, readwrite, nonatomic) NSString* title;
@property (strong, readwrite, nonatomic) NSString* key;
@property (strong, readwrite, nonatomic) NSError* error;
@property (readwrite, nonatomic) BOOL required;
@property (readwrite, nonatomic) BOOL updateAutomatically;
@property (readwrite, nonatomic) NSUInteger currentRevision;
@property (readwrite, nonatomic) NSUInteger lastRevisionValidated;

@end

@implementation CField

@synthesize title = title_;
@synthesize key = key_;
@synthesize value = value_;
@synthesize required = required_;
@synthesize state = state_;
@synthesize updateAutomatically = updateAutomatically_;
@synthesize error = error_;
@synthesize currentRevision = currentRevision_;
@synthesize lastRevisionValidated = lastRevisionValidated_;
@dynamic needsValidation;
@dynamic empty;
@dynamic isValid;

- (void)setup
{
}

- (id)initWithTitle:(NSString*)title key:(NSString*)key value:(id)value required:(BOOL)required updateAutomatically:(BOOL)updateAutomatically
{
	if(self = [super init]) {
		self.title = title;
		self.key = key;
		self.value = value;
		self.required = required;
		self.updateAutomatically = updateAutomatically;
		[self addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];

		[self setup];
	}
	return self;
}

- (void)disarmUpdate
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(update) object:nil];
}

- (void)armUpdate
{
	[self disarmUpdate];
	[self performSelector:@selector(update) withObject:nil afterDelay:0.1];
}

- (void)armUpdateIfNeeded
{
	if(self.needsValidation) {
		if(self.updateAutomatically) {
			[self armUpdate];
		}
	}
}

- (BOOL)needsValidation
{
	return self.currentRevision > self.lastRevisionValidated;
}

- (void)setNeedsValidation:(BOOL)needsValidation
{
	if(needsValidation) {
		self.currentRevision++;
		
		if(self.state != CFieldStateProcessing) {
			[self armUpdateIfNeeded];
		}
	} else {
		self.lastRevisionValidated = self.currentRevision;
	}
}

- (void)dealloc
{
	[self disarmUpdate];
	[self removeObserver:self forKeyPath:@"value"];
	self.updateAutomatically = NO;
}

// Override in subclasses
- (void)validateSuccess:(void (^)(CFieldState state))success failure:(void (^)(NSError* error))failure
{
	if(self.empty) {
		if(self.required) {
			failure([NSError errorWithDomain:CFieldErrorDomain code:CFieldErrorRequired localizedFormat:@"%@ is required.", self.title]);
		} else {
			success(CFieldStateOmitted);
		}
	} else {
		success(CFieldStateValid);
	}
}

+ (NSSet*)keyPathsForValuesAffectingIsValid
{
	return [NSSet setWithObject:@"state"];
}

- (void)update
{
	[self disarmUpdate];
	
	if(self.state != CFieldStateProcessing) {
		if(self.needsValidation) {
			self.needsValidation = NO;
			self.state = CFieldStateProcessing;
			
			void (^finally)(void) = ^{
				[self armUpdateIfNeeded];
			};
			
			[self validateSuccess:^(CFieldState state) {
				self.error = nil;
				self.state = state;
				finally();
			} failure:^(NSError* error) {
				self.error = error;
				self.state = CFieldStateInvalid;
				finally();
			}];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == self) {
		if([keyPath isEqualToString:@"value"]) {
			if(!Same([change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey])) {
				self.needsValidation = YES;
			}
		}
	}
}

- (BOOL)isEmpty
{
	return self.value == nil;
}

- (BOOL)isValid
{
	return self.state == CFieldStateValid || self.state == CFieldStateOmitted;
}

+ (BOOL)automaticallyNotifiesObserversOfValue
{
	return NO;
}

- (id)value
{
	return value_;
}

- (void)setValue:(id)value
{
	if(!Same(value_, value)) {
		[self willChangeValueForKey:@"value"];
		value_ = value;
		[self didChangeValueForKey:@"value"];
	}
}

@end
