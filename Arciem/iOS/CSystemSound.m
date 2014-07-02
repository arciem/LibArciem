/*******************************************************************************
 
 Copyright 2013 Arciem LLC
 
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

#import "CSystemSound.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CSystemSound () {
    SystemSoundID soundID;
}

@end

@implementation CSystemSound

- (instancetype)initWithFileURL:(NSURL*)url
{
    if(self = [super init]) {
#if DEBUG
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        NSAssert2(err == 0, @"Error creating audio object: %ld %@", (long)err, url);
#endif
    }
    return self;
}

- (void)play
{
    AudioServicesPlaySystemSound(soundID);
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(soundID);
}

@end
