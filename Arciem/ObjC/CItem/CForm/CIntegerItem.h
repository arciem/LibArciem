/*******************************************************************************
 
 Copyright 2014 Arciem LLC
 
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

#import <Arciem/Arciem.h>

extern NSString* const CIntegerItemErrorDomain;

enum {
	CIntegerItemErrorInvalidValue = 1000
};

@interface CIntegerItem : CItem

+ (CIntegerItem*)newIntegerItem;
+ (CIntegerItem*)newIntegerItemWithDictionary:(NSDictionary*)dict;
+ (CIntegerItem*)newIntegerItemWithTitle:(NSString*)title key:(NSString*)key integerValue:(NSInteger)integerValue;

@property (nonatomic) NSInteger integerValue;
@property (nonatomic) NSNumber *minValidValue;
@property (nonatomic) NSNumber *maxValidValue;

@end
