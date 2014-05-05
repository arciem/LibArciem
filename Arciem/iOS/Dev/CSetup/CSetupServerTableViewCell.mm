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

#import "CSetupServerTableViewCell.h"

@implementation CSetupServerTableViewCell

@synthesize server = server_;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if(self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return self;
}

- (CSetupServerItem*)server
{
	return server_;
}

- (void)setServer:(CSetupServerItem *)server
{
	server_ = server;
	self.textLabel.text = server.title;
	self.detailTextLabel.text = server.baseURL.absoluteString;
}

@end
