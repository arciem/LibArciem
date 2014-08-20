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

#import "CItem.h"
#import "CBooleanItem.h"
#import "CActionItem.h"
#import "CSectionItem.h"
#import "CCardNumberItem.h"
#import "CPaymentMethodSummaryItem.h"
#import "CDateItem.h"
#import "CEmailItem.h"
#import "CMultiChoiceItem.h"
#import "CMultiTextItem.h"
#import "CNoteItem.h"
#import "CPasswordItem.h"
#import "CPhoneItem.h"
#import "CRepeatingItem.h"
#import "CSpacerItem.h"
#import "CStringItem.h"
#import "CSubmitItem.h"
#import "CIntegerItem.h"

@interface CForm : NSObject

@property (nonatomic) CItem* rootItem;

- (instancetype)initWithRootItem:(CItem*)rootItem;

+ (CForm*)newFormForResourceName:(NSString*)resourceName withExtension:(NSString*)extension;
+ (CForm*)newFormForResourceName:(NSString*)resourceName;
+ (CForm*)newFormWithRootItem:(CItem*)rootItem;

@end
