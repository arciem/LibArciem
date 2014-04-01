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

#import "CTextureAtlas.h"
#import "CTextureAtlasImage.h"

static NSMutableDictionary *sAtlases;

@interface CTextureAtlas ()

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSArray *images;
@property (readonly, nonatomic) NSDictionary *subimagesByName;

@end

@implementation CTextureAtlas

@synthesize name = _name;
@synthesize directoryName = _directoryName;
@synthesize subimagesByName = _subimagesByName;
@synthesize subimageNames = _subimageNames;

+ (CTextureAtlas *)atlasNamed:(NSString *)atlasName {
    if(sAtlases == nil) {
        sAtlases = [NSMutableDictionary new];
    }
    
    CTextureAtlas *atlas = sAtlases[atlasName];
    
    if(atlas == nil) {
        atlas = [[CTextureAtlas alloc] initWithName:atlasName];
        sAtlases[atlasName] = atlas;
    }
    
    return atlas;
}

- (NSString *)directoryName {
    if(_directoryName == nil) {
        _directoryName = [NSString stringWithFormat:@"%@.atlasc", self.name];
    }
    
    return _directoryName;
}

- (id)initWithName:(NSString *)name {
    if(self = [super init]) {
        _name = name;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:_name ofType:@"plist" inDirectory:self.directoryName];
        NSAssert1(plistPath != nil, @"Could not find plist for %@", _name);
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSAssert1(dict != nil, @"Could not read dictionary at %@", plistPath);
        NSArray *imagesDictsArray = dict[@"images"];
        NSMutableArray *imagesMutableArray = [NSMutableArray new];
        for(NSDictionary *imageDict in imagesDictsArray) {
            CTextureAtlasImage *image = [[CTextureAtlasImage alloc] initWithAtlas:self dictionary:imageDict];
            [imagesMutableArray addObject:image];
        }
        _images = [imagesMutableArray copy];
    }
    return self;
}

- (NSDictionary *)subimagesByName {
    if(_subimagesByName == nil) {
        NSMutableDictionary *mutableSubimagesByName = [NSMutableDictionary new];
        for(CTextureAtlasImage *image in self.images) {
            NSArray *subimages = image.subimages;
            for(CTextureAtlasSubimage *subimage in subimages) {
                mutableSubimagesByName[subimage.name] = subimage;
            }
        }
        _subimagesByName = [mutableSubimagesByName copy];
    }
    return _subimagesByName;
}

- (NSArray *)subimageNames {
    if(_subimageNames == nil) {
        _subimageNames = self.subimagesByName.allKeys;
    }
    return _subimageNames;
}

- (CTextureAtlasSubimage *)subimageNamed:(NSString *)name {
    return self.subimagesByName[name];
}

@end
