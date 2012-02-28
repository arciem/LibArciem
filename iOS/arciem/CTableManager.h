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

#import <UIKit/UIKit.h>

@protocol CTableManagerDelegate;

@interface CTableManager : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSURL* modelURL;
@property (weak, nonatomic) IBOutlet id<CTableManagerDelegate> delegate;

- (void)replaceSectionAtIndex:(NSUInteger)sectionIndex withSectionWithKey:(NSString*)newSectionKey;
- (void)replaceSectionWithKey:(NSString*)oldSectionKey withSectionWithKey:(NSString*)newSectionKey;
- (void)deleteRowWithKey:(NSString*)key withRowAnimation:(UITableViewRowAnimation)animation;
- (void)clearSelectionAnimated:(BOOL)animated;

@end

@protocol CTableManagerDelegate <NSObject>

@required
- (void)tableManager:(CTableManager*)tableManager didSelectRow:(NSMutableDictionary*)row atIndexPath:(NSIndexPath *)indexPath;

@end
