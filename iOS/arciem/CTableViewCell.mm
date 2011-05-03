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

#import "CTableViewCell.h"
#import "UIViewUtils.h"

@implementation CTableViewCell

- (void)setup
{
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[self setup];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
//	[self drawCrossedBox:self.bounds color:[UIColor redColor] lineWidth:1.0 originIndicators:YES];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
//	[self setNeedsDisplay];
}

@end
