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

#import "CTextureAtlasImage.h"
#import "CTextureAtlas.h"
#import "ObjectUtils.h"

@interface CTextureAtlasImage ()

@property (weak, readonly, nonatomic) CTextureAtlas *atlas;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) CGSize size;

@end

@implementation CTextureAtlasImage

@synthesize atlas = _atlas;
@synthesize path = _path;
@synthesize size = _size;
@synthesize subimages = _subimages;
@synthesize image = _image;

- (id)initWithAtlas:(CTextureAtlas *)atlas dictionary:(NSDictionary *)dict {
    if(self = [super init]) {
        _atlas = atlas;
        _path = dict[@"path"];
        _size = CGSizeFromString(dict[@"size"]);
        NSArray *subimagesDictsArray = dict[@"subimages"];
        NSMutableArray *subimagesMutableArray = [NSMutableArray new];
        for(NSDictionary *subimageDict in subimagesDictsArray) {
            CTextureAtlasSubimage *subimage = [[CTextureAtlasSubimage alloc] initWithAtlasImage:self dictionary:subimageDict];
            [subimagesMutableArray addObject:subimage];
        }
        _subimages = [subimagesMutableArray copy];
    }
    return self;
}

- (UIImage *)image {
    if(_image == nil) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:self.path ofType:nil inDirectory:self.atlas.directoryName];
        NSAssert1(imagePath != nil, @"No image resource found at %@", imagePath);
        _image = [UIImage imageWithContentsOfFile:imagePath];
        NSAssert1(_image != nil, @"Unable to load image at %@", imagePath);
    }
    
    return _image;
}

@end
