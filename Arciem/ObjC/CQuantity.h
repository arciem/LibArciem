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

#import <Foundation/Foundation.h>


// Dimension identifiers
extern NSString* const kDimensionMass;
extern NSString* const kDimensionDistance;
extern NSString* const kDimensionSpeed;
extern NSString* const kDimensionFluidVolume;
extern NSString* const kDimensionDryVolume;
extern NSString* const kDimensionTemperature;

@class CDimension;
@class CUnit;

@interface CQuantityManager : NSObject

@property(nonatomic, readonly) NSArray* dimensions;
@property(nonatomic, readonly) NSArray* units;

+ (CQuantityManager*)sharedQuantityManager;
- (CDimension*)addDimensionWithIdentifier:(NSString*)identifier name:(NSString*)name;
- (CDimension*)dimensionForIdentifier:(NSString*)identifier;
- (CUnit*)addUnitWithSymbol:(NSString*)symbol name:(NSString*)name dimension:(CDimension*)dimension;
- (CUnit*)unitForSymbol:(NSString*)symbol;

@end

@interface CDimension : NSObject

@property(nonatomic, retain, readonly) NSString* identifier;
@property(nonatomic, retain, readonly) NSString* name;
@property(nonatomic, retain, readonly) CUnit* baseUnit;

- (instancetype)initWithIdentifier:(NSString*)identifier name:(NSString*)name;
+ (CDimension*)dimensionWithIdentifier:(NSString*)identifier name:(NSString*)name;

@end

@interface CUnit : NSObject

@property(nonatomic, retain, readonly) NSString* symbol;
@property(nonatomic, retain, readonly) NSString* name;
@property(nonatomic, retain, readonly) CDimension* dimension;
@property(nonatomic, copy, readonly) double(^toBase)(double);
@property(nonatomic, copy, readonly) double(^fromBase)(double);

- (instancetype)initWithSymbol:(NSString*)symbol name:(NSString*)name dimension:(CDimension*)dimension;
+ (CUnit*)unitWithSymbol:(NSString*)symbol name:(NSString*)name dimension:(CDimension*)dimension;

@end

#if 0
@interface CQuantity : NSObject

@property(nonatomic, readonly) double value;
@property(nonatomic, retain, readonly) CUnit* unit;

- (instancetype)initWithValue:(double)value unit:(NSString*)unit;
- (CQuantity*)quantityWithValue:(double)value unit:(NSString*)unit;

@end
#endif