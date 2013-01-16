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

- (void)addTouch:(UITouch *)touch forParent:(id)polygon with:(id)subShape
{
    const void* cfTouch = (__bridge const void *)touch;
    NSArray* shapes = [[NSArray alloc] initWithObjects:polygon, subShape, nil];
    const void* cfShape = (__bridge const void *)shapes;
    
    if (!CFDictionaryContainsKey(touchDict, cfTouch))       // If the dictionary doesn't have this touch
        CFDictionarySetValue(touchDict, cfTouch, cfShape);
}

- (void)removeTouch:(UITouch *)touch
{
    if (CFDictionaryContainsKey(touchDict, (__bridge const void *)touch))
    {
        //void* cfArray = [self getTouchClassArray:touch];
        //free(cfArray);
        CFDictionaryRemoveValue(touchDict, (__bridge const void *)touch);
    }
}

- (NSArray *)getTouchClassArray:(UITouch *)touch
{
    const void* cfTouch = (__bridge const void *)touch;
    if (CFDictionaryContainsKey(touchDict, cfTouch))
    {
        NSArray* shapeArray = (__bridge NSArray *)CFDictionaryGetValue(touchDict, cfTouch);
        return shapeArray;
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
