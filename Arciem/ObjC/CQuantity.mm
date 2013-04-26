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

/*
 "#": "LENGTH",
 "m": "meters",
 "km": "kilometers",
 "cm": "centimeters",
 "mm": "millimeters",
 "in": "inches",
 "ft": "feet",
 "yd": "yards",
 "mi": "miles",
 
 "#": "MASS",
 "kg": "kilograms",
 "g": "grams",
 "mg": "milligrams",
 "mcg": "micrograms",
 "lb": "pounds",

 "#": "TIME",
 "sec": "seconds",
 "min": "minutes",
 "hr": "hours",
 "day": "days",
 "secz": "rest seconds",
 "minz": "rest minutes",
 "hrz": "rest hours",
 "dayz": "rest days",
 
 "#": "SPEED",
 "mps": "meters per second",
 "kps": "kilometers per second",
 "kph": "kilometers per hour",
 "mph": "miles per hour",
 
 "#": "TEMPERATURE",
 "F": "degrees fahrenheit",
 "C": "degrees celsius",
 
 "#": "WORKOUT",
 "x": "sets",
 "r": "repetitions",
 
 "#": "FLUID VOLUME",
 "L": "liters",
 "ml": "milliliters",
 "ozfl": "ounces, fluid",
 "tsp": "teaspoons",
 "tbsp": "tablespoons",
 "cup": "cups",
 "pt": "pints",
 "pt-uk": "UK pints",
 "ozfl-uk": "UK ounces, fluid",
 "qt": "quarts",
 "gal": "gallons",
 
 "#": "DRY VOLUME",
 "oz": "ounces, dry",
 
 "#": "PACKAGING",
 "bottle": "bottles",
 "can": "cans",
 "box": "boxes",
 "container": "containers",
 "cube": "cubes",
 "each": "each",
 "jars": "jars",
 "package": "packages",
 "piece": "pieces",
 "scoop": "scoops",
 "serving": "servings",
 "slice": "slices",
 "stick": "sticks",
 "tablet": "tablets"
*/

#import "CQuantity.h"

static CQuantityManager* sQuantityManager = nil;
//static NSMutableDictionary* sDimensions = nil;
//static NSMutableDictionary* sUnits = nil;

NSString* const kDimensionTime = @"kDimensionTime";
NSString* const kDimensionMass = @"kDimensionMass";
NSString* const kDimensionLength = @"kDimensionLength";
NSString* const kDimensionSpeed = @"kDimensionSpeed";
NSString* const kDimensionFluidVolume = @"kDimensionFluidVolume";
NSString* const kDimensionDryVolume = @"kDimensionDryVolume";
NSString* const kDimensionTemperature = @"kDimensionTemperature";
NSString* const kDimensionPackaging = @"kDimensionPackaging";

@interface CQuantityManager ()

@property(nonatomic, retain, readwrite) NSMutableDictionary* dimensionsDict;
@property(nonatomic, retain, readwrite) NSMutableDictionary* unitsDict;

@end

@interface CDimension ()

@property(nonatomic, retain, readwrite) NSString* identifier;
@property(nonatomic, retain, readwrite) NSString* name;
@property(nonatomic, retain, readwrite) CUnit* baseUnit;

@end

@interface CUnit ()

@property(nonatomic, retain, readwrite) NSString* symbol;
@property(nonatomic, retain, readwrite) NSString* name;
@property(nonatomic, retain, readwrite) CDimension* dimension;
@property(nonatomic, copy, readwrite) double(^toBase)(double);
@property(nonatomic, copy, readwrite) double(^fromBase)(double);

@end

@implementation CQuantityManager

@synthesize dimensionsDict = dimensionsDict_;
@synthesize unitsDict = unitsDict_;
@dynamic dimensions;
@dynamic units;

- (NSArray*)dimensions
{
	return self.dimensionsDict.allValues;
}

- (NSArray*)units
{
	return self.unitsDict.allValues;
}

- (void)setup
{
	self.dimensionsDict = [NSMutableDictionary dictionary];
	self.unitsDict = [NSMutableDictionary dictionary];
	
	CDimension* length = [self addDimensionWithIdentifier:kDimensionLength name:@"length"];
	CDimension* mass = [self addDimensionWithIdentifier:kDimensionMass name:@"mass"];
	CDimension* time = [self addDimensionWithIdentifier:kDimensionTime name:@"time"];
	CDimension* speed = [self addDimensionWithIdentifier:kDimensionSpeed name:@"speed"];
	CDimension* temp = [self addDimensionWithIdentifier:kDimensionTemperature name:@"temperature"];
	CDimension* dryVol = [self addDimensionWithIdentifier:kDimensionDryVolume name:@"dry volume"];
	CDimension* fluidVol = [self addDimensionWithIdentifier:kDimensionFluidVolume name:@"fluid volume"];
	CDimension* packagaing = [self addDimensionWithIdentifier:kDimensionPackaging name:@"packaging"];
	
	
	CUnit* meter = [self addUnitWithSymbol:@"m" name:@"meter" dimension:length];
	length.baseUnit = meter;
	meter.toBase = ^(double m) { return m; };
	meter.fromBase = ^(double m) { return m; };
	
	CUnit* kilometer = [self addUnitWithSymbol:@"km" name:@"kilometer" dimension:length];
	kilometer.toBase = ^(double km) { return km * 1.0e3; };
	kilometer.fromBase = ^(double m) { return m * 1.0e-3; };
	
	CUnit* centimeter = [self addUnitWithSymbol:@"cm" name:@"centimeter" dimension:length];
	centimeter.toBase = ^(double cm) { return cm * 1.0e-2; };
	centimeter.fromBase = ^(double m) { return m * 1.0e2; };

	CUnit* millimeter = [self addUnitWithSymbol:@"mm" name:@"millimeter" dimension:length];
	millimeter.toBase = ^(double mm) { return mm * 1.0e-3; };
	millimeter.fromBase = ^(double m) { return m * 1.0e3; };

	CUnit* inch = [self addUnitWithSymbol:@"in" name:@"inch" dimension:length];
	inch.toBase = ^(double inch) { return inch * 0.0254; };
	inch.fromBase = ^(double m) { return m * 39.3700787; };

	CUnit* foot = [self addUnitWithSymbol:@"ft" name:@"foot" dimension:length];
	foot.toBase = ^(double foot) { return foot * 0.3048; };
	foot.fromBase = ^(double m) { return m * 3.2808399; };
	
	CUnit* yard = [self addUnitWithSymbol:@"yd" name:@"yard" dimension:length];
	yard.toBase = ^(double yard) { return yard * 0.9144; };
	yard.fromBase = ^(double m) { return m * 1.0936133; };
	
	CUnit* mile = [self addUnitWithSymbol:@"mi" name:@"mile" dimension:length];
	mile.toBase = ^(double mile) { return mile * 1609.344; };
	mile.fromBase = ^(double m) { return m * 0.000621371192; };
	
	
	CUnit* kilogram = [self addUnitWithSymbol:@"kg" name:@"kilogram" dimension:mass];
	mass.baseUnit = kilogram;
	kilogram.toBase = ^(double kg) { return kg; };
	kilogram.fromBase = ^(double kg) { return kg; };
	
	CUnit* gram = [self addUnitWithSymbol:@"g" name:@"gram" dimension:mass];
	gram.toBase = ^(double g) { return g * 1.0e-3; };
	gram.fromBase = ^(double kg) { return kg * 1.0e3; };
	
	CUnit* milligram = [self addUnitWithSymbol:@"mg" name:@"milligram" dimension:mass];
	milligram.toBase = ^(double mg) { return mg * 1.0e-6; };
	milligram.fromBase = ^(double kg) { return kg * 1.0e6; };
	
	CUnit* microgram = [self addUnitWithSymbol:@"mcg" name:@"microgram" dimension:mass];
	microgram.toBase = ^(double mcg) { return mcg * 1.0e-9; };
	microgram.fromBase = ^(double kg) { return kg * 1.0e9; };
	
	CUnit* pound = [self addUnitWithSymbol:@"lb" name:@"pound" dimension:mass];
	pound.toBase = ^(double lb) { return lb * 0.45359237; };
	pound.fromBase = ^(double kg) { return kg * 2.20462262; };
	
	
	CUnit* second = [self addUnitWithSymbol:@"sec" name:@"second" dimension:time];
	time.baseUnit = second;
	second.toBase = ^(double sec) { return sec; };
	second.fromBase = ^(double sec) { return sec; };
	
	CUnit* minute = [self addUnitWithSymbol:@"min" name:@"minute" dimension:time];
	minute.toBase = ^(double min) { return min * 60.0; };
	minute.fromBase = ^(double sec) { return sec / 60.0; };
	
	CUnit* hour = [self addUnitWithSymbol:@"hr" name:@"hour" dimension:time];
	hour.toBase = ^(double hr) { return hr * 3600.0; };
	hour.fromBase = ^(double sec) { return sec / 3600.0; };
	
	CUnit* day = [self addUnitWithSymbol:@"day" name:@"day" dimension:time];
	day.toBase = ^(double day) { return day * 86400.0; };
	day.fromBase = ^(double sec) { return sec / 86400.0; };
	
	
	CUnit* mps = [self addUnitWithSymbol:@"mps" name:@"meter per second" dimension:speed];
	speed.baseUnit = mps;
	mps.toBase = ^(double mps) { return mps; };
	mps.fromBase = ^(double mps) { return mps; };
	
	CUnit* kps = [self addUnitWithSymbol:@"kps" name:@"kilometer per second" dimension:speed];
	kps.toBase = ^(double kps) { return kps * 1.0e3; };
	kps.fromBase = ^(double mps) { return mps * 1.0e-3; };
	
	CUnit* kph = [self addUnitWithSymbol:@"kph" name:@"kilometer per hour" dimension:speed];
	kph.toBase = ^(double kph) { return kph * 0.277777778; };
	kph.fromBase = ^(double mps) { return mps * 3.6; };
	
	CUnit* mph = [self addUnitWithSymbol:@"mph" name:@"mile per hour" dimension:speed];
	mph.toBase = ^(double mph) { return mph * 0.44704; };
	mph.fromBase = ^(double mps) { return mps * 2.23693629; };
	
	
	CUnit* celsius = [self addUnitWithSymbol:@"C" name:@"degrees celsius" dimension:temp];
	temp.baseUnit = celsius;
	celsius.toBase = ^(double celsius) { return celsius; };
	celsius.fromBase = ^(double celsius) { return celsius; };
	
	CUnit* fahrenheit = [self addUnitWithSymbol:@"F" name:@"degrees fahrenheit" dimension:temp];
	fahrenheit.toBase = ^(double f) { return (f - 32.0) * (5.0 / 9.0); };
	fahrenheit.fromBase = ^(double c) { return (c * 9.0 / 5.0) + 32.0; };
	
	CUnit* dryOunce = [self addUnitWithSymbol:@"oz" name:@"ounce, dry" dimension:dryVol];
	dryVol.baseUnit = dryOunce;
	
	CUnit* fluidOunce = [self addUnitWithSymbol:@"ozfl" name:@"ounce, fluid" dimension:fluidVol];
	fluidVol.baseUnit = fluidOunce;
	
	[self addUnitWithSymbol:@"bottle" name:@"bottle" dimension:packagaing];
	[self addUnitWithSymbol:@"can" name:@"can" dimension:packagaing];
	[self addUnitWithSymbol:@"box" name:@"box" dimension:packagaing];
}

- (id)init
{
	if(sQuantityManager == nil) {
		if((self = [super init])) {
			sQuantityManager = self;
			[self setup];
		}
	} else {
		self = sQuantityManager;
	}
	return self;
}

+ (CQuantityManager*)sharedQuantityManager
{
	if(sQuantityManager == nil) {
		sQuantityManager = [[CQuantityManager alloc] init];
	}
	return sQuantityManager;
}

#if 0
- (id)retain
{
	return self;
}

- (void)release
{
}
#endif

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}

- (CDimension*)addDimensionWithIdentifier:(NSString*)identifier name:(NSString*)name
{
	CDimension* dimension = nil;
	
	CDimension* existingDimension = (self.dimensionsDict)[identifier];
	if(existingDimension != nil) {
		[NSException raise:@"Duplicate dimension identifier" format:@"Dimension identifier %@ already exists.", existingDimension.identifier];
	} else {
		dimension = [CDimension dimensionWithIdentifier:identifier name:name];
		(self.dimensionsDict)[identifier] = dimension;
	}
	
	return dimension;
}

- (CDimension*)dimensionForIdentifier:(NSString*)identifier
{
	return (self.dimensionsDict)[identifier];
}

- (CUnit*)addUnitWithSymbol:(NSString*)symbol name:(NSString*)name dimension:(CDimension*)dimension
{
	CUnit* unit = nil;
	
	CUnit* existingUnit = (self.unitsDict)[symbol];
	if(existingUnit != nil) {
		[NSException raise:@"Duplicate unit symbol" format:@"Symbol %@ already exists.", existingUnit.symbol];
	} else {
		unit = [CUnit unitWithSymbol:symbol name:name dimension:dimension];
		(self.unitsDict)[symbol] = unit;
	}

	return unit;
}

- (CUnit*)unitForSymbol:(NSString*)symbol
{
	return (self.unitsDict)[symbol];
}

@end

@implementation CDimension

@synthesize identifier = identifier_;
@synthesize name = name_;
@synthesize baseUnit = baseUnit_;

- (id)initWithIdentifier:(NSString*)identifier name:(NSString*)name
{
	if((self = [super init])) {
		self.identifier = identifier;
		self.name = name;
	}
	return self;
}

- (void)dealloc
{
	self.identifier = nil;
	self.name = nil;
	self.baseUnit = nil;
}

+ (CDimension*)dimensionWithIdentifier:(NSString*)identifier name:(NSString*)name
{
	return [[CDimension alloc] initWithIdentifier:identifier name:name];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"[%@ identifier:%@ name:'%@' baseUnit:%@]", [super description], self.identifier, self.name, self.baseUnit == nil ? @"none" : self.baseUnit.symbol];
}

@end

@implementation CUnit

@synthesize symbol = symbol_;
@synthesize name = name_;
@synthesize dimension = dimension_;
@synthesize toBase = toBase_;
@synthesize fromBase = fromBase_;

- (id)initWithSymbol:(NSString*)symbol name:(NSString*)name dimension:(CDimension*)dimension
{
	if((self = [super init])) {
		self.symbol = symbol;
		self.name = name;
		self.dimension = dimension;
	}
	return self;
}

- (void)dealloc
{
	self.symbol = nil;
	self.name = nil;
	self.dimension = nil;
	self.toBase = nil;
	self.fromBase = nil;
}

+ (CUnit*)unitWithSymbol:(NSString*)symbol name:(NSString*)name dimension:(CDimension*)dimension
{
	return [[CUnit alloc] initWithSymbol:symbol name:name dimension:dimension];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"[%@ symbol:%@ name:'%@' dimension:%@]", [super description], self.symbol, self.name, self.dimension.identifier];
}

@end

#if 0
@interface CQuantity ()

@property(nonatomic, readwrite) double value;
@property(nonatomic, retain, readwrite) NSString* unit;
@property(nonatomic, retain, readwrite) NSString* dimension;

@end

@implementation CQuantity

@synthesize value = value_;
@synthesize unit = unit_;
@synthesize dimension = dimension_;

- (id)initWithValue:(double)value unit:(NSString*)unit dimension:(NSString*)dimension
{
	if((self = [super init])) {
		self.value = value;
		self.unit = unit;
		self.dimension = dimension;
	}
	
	return self;
}

- (void)dealloc
{
	self.unit = nil;
	self.dimension = nil;
	[super dealloc];
}

- (CQuantity*)quantityWithValue:(double)value unit:(NSString*)unit dimension:(NSString*)dimension
{
	return [[[CQuantity alloc] initWithValue:value unit:unit dimension:dimension] autorelease];
}

@end
#endif