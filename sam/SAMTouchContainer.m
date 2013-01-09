//
//  SAMTouchContainer.m
//  sam
//
//  Created by Scott McCoid on 1/9/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMTouchContainer.h"

#define MAX_TOUCHES 5

@implementation SAMTouchContainer

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
    const void** cfArray = malloc(sizeof(void *) * 2);
    
    cfArray[0] = (__bridge const void *)[object class];
    cfArray[1] = cfObject;
    
    if (!CFDictionaryContainsKey(touchDict, cfTouch))       // If the dictionary doesn't have this touch
    {
        CFDictionarySetValue(touchDict, cfTouch, cfArray);
    }
}

- (void)removeTouch:(UITouch *)touch
{
    if (CFDictionaryContainsKey(touchDict, (__bridge const void *)touch))
    {
        void* cfArray = [self getTouchClassArray:touch];
        free(cfArray);
        CFDictionaryRemoveValue(touchDict, (__bridge const void *)touch);
    }
}

- (const void *)getTouchClassArray:(UITouch *)touch
{
    const void* cfTouch = (__bridge const void *)touch;
    if (CFDictionaryContainsKey(touchDict, cfTouch))
    {
        const void* cfArray = CFDictionaryGetValue(touchDict, cfTouch);
        return cfArray;
    }
    else
        return nil;
}

- (BOOL)isInContainer:(UITouch *)touch
{
    if (CFDictionaryContainsKey(touchDict, (__bridge const void *)(touch)))
        return YES;
    else
        return NO;
}

@end
