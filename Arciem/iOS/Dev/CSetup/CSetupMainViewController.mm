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

#import "CSetupMainViewController.h"
#import "CSetupServerTableViewCell.h"
#import "CSetupEditServerViewController.h"
#import "CSetupNavigationController.h"
#import "CBooleanItem.h"
#import "CSetupBoolOptionTableViewCell.h"
#import "DeviceUtils.h"
#import "CForm.h"
#import "CObserver.h"
#import "UIViewUtils.h"

@interface CSetupMainViewController () <UITableViewDataSource, UITableViewDelegate, SetupEditServerViewControllerDelegate>

@property (nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSURL* baseURL;
@property (copy, nonatomic) NSURL* oldBaseURL;
@property (readonly, nonatomic) NSArray* testingServers;
@property (nonatomic, readonly) CSetupServerItem* defaultServer;
@property (readonly, nonatomic) NSMutableArray* devServers;
@property (nonatomic) UIBarButtonItem* startButtonItem;
@property (nonatomic) NSIndexPath* editingIndexPath;
@property (readonly, nonatomic) NSArray* options;
@property (nonatomic) NSUInteger testingServersSectionIndex;
@property (nonatomic) NSUInteger devServersSectionIndex;
@property (nonatomic) NSUInteger optionsSectionIndex;
@property (nonatomic) CForm* form;
@property (nonatomic) NSMutableArray* observers;
@property (nonatomic) BOOL addCellRemoved;

- (NSIndexPath*)addCellIndexPath;

@end

@implementation CSetupMainViewController

@dynamic baseURL;
@dynamic devServers;
@dynamic defaultServer;
@dynamic testingServersSectionIndex;
@dynamic devServersSectionIndex;
@dynamic optionsSectionIndex;
@synthesize startButtonItem = startButtonItem_;
@synthesize editingIndexPath = editingIndexPath_;
@synthesize delegate = delegate_;
@synthesize oldBaseURL = oldBaseURL_;
@synthesize form = form_;
@synthesize observers = observers_;

- (NSUInteger)testingServersSectionIndex
{
	return self.editing ? NSNotFound : 0;
}

- (NSUInteger)devServersSectionIndex
{
	return self.editing ? 0 : 1;
}

- (NSUInteger)optionsSectionIndex
{
	return self.editing ? NSNotFound : 2;
}

- (NSArray*)testingServers
{
	return [self.form.rootItem valueForKeyPath:@"servers.subitems"];
}

- (CSetupServerItem*)defaultServer
{
	return (self.testingServers)[0];
}

- (NSMutableArray*)devServers
{
	return [self mutableArrayValueForKey:@"devServers_"];
}

- (NSArray*)options
{
	return [self.form.rootItem valueForKeyPath:@"options.subitems"];
}

- (NSURL*)baseURL
{
	return [[NSUserDefaults standardUserDefaults] URLForKey:@"baseURL"];
}

- (void)setBaseURL:(NSURL*)baseURL
{
	[[NSUserDefaults standardUserDefaults] setURL:baseURL forKey:@"baseURL"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

// "devServers2" is a new version that uses CSetupServerItems (a subclass of CItem) and a JSON storage format, which replaced "devServers", which simply used an NSDictionary/property list item format.
- (NSUInteger)countOfDevServers_
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"devServers2"].count;
}

- (id)objectInDevServers_AtIndex:(NSUInteger)index
{
	NSString* json = [[NSUserDefaults standardUserDefaults] arrayForKey:@"devServers2"][index];
	return [[CSetupServerItem alloc] initWithJSONRepresentation:json];
}

- (void)insertObject:(CSetupServerItem*)server inDevServers_AtIndex:(NSUInteger)index
{
	NSMutableArray* a = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"devServers2"] mutableCopy];
	[a insertObject:server.jsonRepresentation atIndex:index];
	[[NSUserDefaults standardUserDefaults] setObject:a forKey:@"devServers2"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectFromDevServers_AtIndex:(NSUInteger)index
{
	NSMutableArray* a = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"devServers2"] mutableCopy];
	[a removeObjectAtIndex:index];
	[[NSUserDefaults standardUserDefaults] setObject:a forKey:@"devServers2"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	self.tableView.allowsSelectionDuringEditing = YES;
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[self.view constrainCenterEqualToCenterOfItem:self.tableView]];
    [self.view addConstraints:[self.view constrainSizeToSizeOfItem:self.tableView]];
    
}

- (void)setupForm {
    self.form = [CForm newFormForResourceName:@"SetupConfig"];
//		[self.form.rootItem printHierarchy];
    NSMutableDictionary* defaults = [@{
                                       @"baseURL": [NSKeyedArchiver archivedDataWithRootObject:self.defaultServer.baseURL],
                                       @"devServers2": @[]
                                       } mutableCopy];
    for(CItem* optionItem in self.options) {
        id defaultValue = optionItem.defaultValue;
        if(defaultValue != nil) {
            defaults[optionItem.key] = defaultValue;
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.oldBaseURL = self.baseURL;
    
    // Ensure that a valid, existing server is always checked.
    NSArray* allServers = [self.testingServers arrayByAddingObjectsFromArray:self.devServers];
    NSUInteger foundIndex = [allServers indexOfObjectPassingTest:^BOOL(CSetupServerItem* server, NSUInteger idx, BOOL *stop) {
        BOOL match = [server.baseURL isEqual:self.baseURL];
        if(match) *stop = YES;
        return match;
    }];
    if(foundIndex == NSNotFound) {
        self.baseURL = self.defaultServer.baseURL;
    }
    for(CItem* optionItem in self.options) {
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:optionItem.key];
        optionItem.value = value;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)start
{
	BOOL changed = !Same(self.baseURL, self.oldBaseURL);
	[self.delegate setupMainViewController:self didFinishChangingServer:changed];
}

- (void)setupNavigationBar {
	self.navigationItem.title = @"Setup";
	self.startButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:self action:@selector(start)];
	
	if(!self.tableView.editing) {
		self.navigationItem.leftBarButtonItem = self.startButtonItem;
	}
}

#pragma mark - View lifecycle

- (void)syncEditButtonAnimated:(BOOL)animated
{
	UIBarButtonItem* item = self.devServers.count > 0 ? self.editButtonItem : nil;
	[self.navigationItem setRightBarButtonItem:item animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupForm];
    [self setupNavigationBar];
	[self syncEditButtonAnimated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	NSArray* addCellIndexPathsBeforeChange = @[[self addCellIndexPath]];

	[super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];

	NSMutableIndexSet* sectionsRemovedDuringEditing = [NSMutableIndexSet indexSetWithIndex:0];
    if(self.options.count > 0) {
        [sectionsRemovedDuringEditing addIndex:2];
    }

	if(editing) {
		[self.navigationItem setLeftBarButtonItem:nil animated:animated];
		[self.tableView beginUpdates];
		[self.tableView deleteSections:sectionsRemovedDuringEditing withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteRowsAtIndexPaths:addCellIndexPathsBeforeChange withRowAnimation:UITableViewRowAnimationFade];
        self.addCellRemoved = YES;
		[self.tableView endUpdates];
	} else {
		[self.navigationItem setLeftBarButtonItem:self.startButtonItem animated:animated];
		[self.tableView beginUpdates];
		[self.tableView insertSections:sectionsRemovedDuringEditing withRowAnimation:UITableViewRowAnimationFade];
		NSArray* indexPaths = @[[self addCellIndexPath]];
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        self.addCellRemoved = NO;
		[self.tableView endUpdates];
		[self syncEditButtonAnimated:animated];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	self.observers = [NSMutableArray array];
	for(CItem* optionItem in self.options) {
		CObserver* observer = [CObserver newObserverWithKeyPath:@"value" ofObject:optionItem action:^(id object, id newValue, id oldValue, NSKeyValueChange kind, NSIndexSet *indexes) {
			NSString* key = optionItem.key;
//			CLogDebug(nil, @"newValue:%@ key:%@", newValue, key);
			[[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
		}];
		[self.observers addObject:observer];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	self.observers = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger sections;
	
	if(self.editing) {
		sections = 1;
	} else {
		sections = 2;
        if(self.options.count > 0) sections++;
	}
	
	return sections;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* sectionTitle = nil;
	
	static NSArray* sectionTitles = @[@"Testing Servers", @"Development Servers"];
    if(self.options.count > 0) sectionTitles = [sectionTitles arrayByAddingObject:@"Options"];

	if(self.editing) {
		sectionTitle = sectionTitles[1];
	} else {
		sectionTitle = sectionTitles[section];
	}
	
	return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rowCount = 0;
	
	if(self.editing) {
		rowCount = self.devServers.count;
	} else {
		if(section == 0) {
			rowCount = self.testingServers.count;
		} else if(section == 1) {
			rowCount = self.devServers.count;
			if(!self.addCellRemoved) {
				rowCount++;
			}
		} else if(section == 2) {
			rowCount = self.options.count;
		}
	}
	
	return rowCount;
}

- (void)syncCheckmarkForCell:(CSetupServerTableViewCell*)cell
{
	cell.accessoryType = [cell.server.baseURL isEqual:self.baseURL] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

-(void)syncCheckmarksForAllVisibleCells
{
	for(UITableViewCell* cell in self.tableView.visibleCells) {
		if([cell isKindOfClass:[CSetupServerTableViewCell class]]) {
			CSetupServerTableViewCell* setupCell = (CSetupServerTableViewCell*)cell;
			[self syncCheckmarkForCell:setupCell];
		}
	}
}

- (NSIndexPath*)addCellIndexPath
{
	NSIndexPath* indexPath = nil;
	
	indexPath = [NSIndexPath indexPathForRow:self.devServers.count inSection:self.devServersSectionIndex];

	return indexPath;
}

- (BOOL)isTestingServerIndexPath:(NSIndexPath*)indexPath
{
	BOOL match = NO;
	
	if(!self.editing) {
		match = indexPath.section == 0;
	}
	
	return match;
}

- (BOOL)isDevServerIndexPath:(NSIndexPath*)indexPath
{
	BOOL match = YES;
	
	if(!self.editing) {
		match = indexPath.section == 1 && (NSUInteger)indexPath.row != self.devServers.count;
	}
	
	return match;
}

- (BOOL)isServerIndexPath:(NSIndexPath*)indexPath
{
	return [self isTestingServerIndexPath:indexPath] || [self isDevServerIndexPath:indexPath];
}

- (CSetupServerItem*)serverForIndexPath:(NSIndexPath*)indexPath
{
	CSetupServerItem* server = nil;
	
	if([self isTestingServerIndexPath:indexPath]) {
		server = (self.testingServers)[indexPath.row];
	} else if([self isDevServerIndexPath:indexPath]) {
		server = (self.devServers)[indexPath.row];
	}
	
	return server;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = nil;
	
	if([[self addCellIndexPath] isEqual:indexPath]) {
		static NSString *sIdentifier = @"AddCell";
		cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sIdentifier];
		}
		
		cell.textLabel.text = @"Add a Server...";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if((NSUInteger)indexPath.section == self.optionsSectionIndex) {
		CItem* option = (self.options)[indexPath.row];
		if([option isKindOfClass:[CBooleanItem class]]) {
			static NSString* sIdentifier = @"BoolOptionCell";
			CSetupBoolOptionTableViewCell* optionCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
			if(optionCell == nil) {
				optionCell = [[CSetupBoolOptionTableViewCell alloc] initWithReuseIdentifier:sIdentifier];
			}
			
			optionCell.option = option;
			
			cell = optionCell;
		} else {
			NSAssert1(NO, @"Unknown option class:%@", [option class]);
		}
	} else {
		static NSString *sIdentifier = @"ServerCell";
		CSetupServerTableViewCell *setupCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
		if (setupCell == nil) {
			setupCell = [[CSetupServerTableViewCell alloc] initWithReuseIdentifier:sIdentifier];
		}
		
		if([self isTestingServerIndexPath:indexPath]) {
			CSetupServerItem* server = (self.testingServers)[indexPath.row];
			setupCell.server = server;
		} else if([self isDevServerIndexPath:indexPath]) {
			CSetupServerItem* server = (self.devServers)[indexPath.row];
			setupCell.server = server;
		}
		
		[self syncCheckmarkForCell:setupCell];
		
		cell = setupCell;
	}
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL can = NO;
	
	if(self.editing) {
		can = [self isDevServerIndexPath:indexPath];
	}

	return can;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	CSetupServerItem* movedServer = (self.devServers)[fromIndexPath.row];
	[self.devServers removeObjectAtIndex:fromIndexPath.row];
	[self.devServers insertObject:movedServer atIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CSetupServerItem* deletedServer = (self.devServers)[indexPath.row];
	if([self.baseURL isEqual:deletedServer.baseURL]) {
		self.baseURL = self.defaultServer.baseURL;
		[self syncCheckmarksForAllVisibleCells];
	}
	[self.devServers removeObjectAtIndex:indexPath.row];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)presentServerEditorForIndexPath:(NSIndexPath*)indexPath
{
	self.editingIndexPath = indexPath;

	CSetupEditServerViewController* viewController = [CSetupEditServerViewController new];
	viewController.delegate = self;

	if(indexPath == nil) {
		viewController.addingNewServer = YES;
	} else {
		viewController.server = (self.devServers)[indexPath.row];
	}

//	CSetupNavigationController* navController = [[CSetupNavigationController alloc] initWithRootViewController:viewController];
//	navController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self.navigationController presentViewController:navController animated:YES completion:NULL];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath* result = indexPath;
	
	if((NSUInteger)indexPath.section == self.optionsSectionIndex) {
		result = nil;
	}
	
	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.editing) {
		[self presentServerEditorForIndexPath:indexPath];
	} else {
		if([[self addCellIndexPath] isEqual:indexPath]) {
			[self presentServerEditorForIndexPath:nil];
		} else {
			if([self isTestingServerIndexPath:indexPath]) {
				CSetupServerItem* server = (self.testingServers)[indexPath.row];
				self.baseURL = server.baseURL;
			} else if([self isDevServerIndexPath:indexPath]) {
				CSetupServerItem* server = (self.devServers)[indexPath.row];
				self.baseURL = server.baseURL;
			}
			
			[self syncCheckmarksForAllVisibleCells];
			
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self isDevServerIndexPath:indexPath] ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self isDevServerIndexPath:indexPath];
}

#pragma mark - SetupEditServerViewControllerDelegate

- (void)setupEditServerViewController:(CSetupEditServerViewController*)viewController didFinishSaving:(BOOL)saving
{
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	if(saving) {
		if(self.editingIndexPath == nil) {
			NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:self.devServers.count inSection:1];
			[self.devServers addObject:viewController.server];
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			[self syncEditButtonAnimated:YES];
		} else {
			CSetupServerItem* editedServer = [self serverForIndexPath:self.editingIndexPath];
			if([self.baseURL isEqual:editedServer.baseURL]) {
				self.baseURL = viewController.server.baseURL;
				[self syncCheckmarksForAllVisibleCells];
			}
			(self.devServers)[self.editingIndexPath.row] = viewController.server;
			[self.tableView reloadRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	}
}

@end
