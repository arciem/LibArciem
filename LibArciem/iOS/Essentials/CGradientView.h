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

#import "CView.h"
#import <QuartzCore/QuartzCore.h>

@interface CGradientView : CView

@property (nonatomic, readonly) CAGradientLayer *gradientLayer;

// Accepts array of UIColor objects or CGColorRefs.
@property (nonatomic, retain) NSArray *colors;

@property (nonatomic, retain) NSArray *locations;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic, copy) NSString *type;

@end
