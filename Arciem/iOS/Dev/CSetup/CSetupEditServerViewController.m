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

#import "CSetupEditServerViewController.h"
#import "CSetupTextFieldTableViewCell.h"
#import "UIViewUtils.h"
#import "StringUtils.h"
#import "CAlertManager.h"

@interface CSetupEditServerViewController ()

@property(nonatomic) NSString* baseURLString;

@end

@implementation CSetupEditServerViewController

@synthesize server = _server;

- (CSetupServerItem*)server
{
	if(_server == nil) {
		_server = [CSetupServerItem new];
	}
	return _server;
}

- (void)setServer:(CSetupServerItem *)server
{
	_server = server;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.title = self.addingNewServer ? @"Add Server" : @"Edit Server";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	
	self.baseURLString = [self.server.baseURL absoluteString];
}

- (void)endEditing
{
	[self.view resignAnyFirstResponder];
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	[self.delegate setupEditServerViewController:self didFinishSaving:NO];
    [self dismiss];
}

- (BOOL)validate
{
	BOOL valid = YES;
	
	NSString* message = nil;
	if(IsEmptyString(self.server.title)) {
		message = @"Name may not be empty.";
	} else {
		if(self.server.baseURL == nil || IsEmptyString(self.server.baseURL.scheme) || IsEmptyString(self.server.baseURL.host)) {
			message = @"URL is not valid. (Don’t forget the “http://” or “https://”.)";
		}
	}

	if(!IsEmptyString(message)) {
		valid = NO;
		[[CAlertManager sharedAlertManager] showAlertWithTitle:nil message:message];
	}
	
	return valid;
}

- (void)save
{
	[self endEditing];

	if([self validate]) {
		[self.delegate setupEditServerViewController:self didFinishSaving:YES];
        [self dismiss];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	CSetupTextFieldTableViewCell* cell = (CSetupTextFieldTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell.textField becomeFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CSetupTextFieldTableViewCell* cell = nil;
	
	static NSString *CellIdentifier = @"FieldCell";
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) {
		cell = [[CSetupTextFieldTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
	}

	cell.textField.tag = indexPath.row;

	cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
	cell.textField.enablesReturnKeyAutomatically = NO;
	cell.textField.returnKeyType = UIReturnKeyDone;
	cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	if([cell.textField respondsToSelector:@selector(setSpellCheckingType:)]) {
		cell.textField.spellCheckingType = UITextSpellCheckingTypeNo;
	}
	
	if(indexPath.row == 0) {
		cell.textLabel.text = @"Name";
		cell.textField.placeholder = @"Server name";
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		cell.textField.keyboardType = UIKeyboardTypeDefault;

		cell.textField.text = self.server.title;
	} else if(indexPath.row == 1) {
		cell.textLabel.text = @"URL";
		cell.textField.placeholder = @"Full Server URL";
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		cell.textField.keyboardType = UIKeyboardTypeURL;
		
		cell.textField.text = self.baseURLString;
	}

	cell.textField.delegate = self;

	cell.textFieldLeft = 70;
	    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self endEditing];
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(textField.tag == 0) {
		self.server.title = textField.text;
	} else if(textField.tag == 1) {
		if(!IsEmptyString(textField.text)) {
			self.baseURLString = textField.text;
            NSURL *baseURL = [NSURL URLWithString:self.baseURLString];
            if(baseURL != nil) {
                self.server.baseURL = baseURL;
            }
		} else {
			self.baseURLString = nil;
		}
	}
}

@end
