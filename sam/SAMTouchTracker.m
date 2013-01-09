//
//  SAMTouchTracker.m
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMTouchTracker.h"

#define MAX_TOUCHES 5

@implementation SAMTouchTracker

- (id)init
{
    self = [super init];
    
    if (self)
    {
        touchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, MAX_TOUCHES, NULL, NULL);
    }
    
    return self;
}

- (void)addTouch:(UITouch *)touch with:(id)object
{
    const void* cfTouch = (__bridge const void *)touch;
    const void* cfObject = (__bridge const void *)object;
    if (!CFDictionaryContainsKey(touchDict, cfTouch))       // If the dictionary doesn't have this touch
    {
        CFDictionarySetValue(touchDict, cfTouch, cfObject);
    }
}

- (id)getTouch:(UITouch *)touch
{
    const void* cfTouch = (__bridge const void *)touch;
    if (CFDictionaryContainsKey(touchDict, cfTouch))
    {
        //BOOL test = [self isKindOfClass:[SomeClass class]];
        
    }
}

@end
