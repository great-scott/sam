//
//  SAMTouchContainer.m
//  sam
//
//  Created by Scott McCoid on 1/9/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMTouchContainer.h"

@implementation SAMTouchContainer

- (id)init
{
    self = [super init];
    
    if (self)
    {
        touchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, MAX_TOUCHES, NULL, NULL);
        for (int i = 0; i < MAX_TOUCHES; i++)
            touchArray[i] = NULL;
    }
    
    return self;
}

- (void)addTouch:(UITouch *)touch forParent:(id)polygon with:(id)subShape
{
//    const void* cfTouch = (__bridge const void *)touch;
//    NSArray* shapes = [[NSArray alloc] initWithObjects:polygon, subShape, nil];
//    const void* cfShape = (__bridge_retained const void *)shapes;
//    
//    if (!CFDictionaryContainsKey(touchDict, cfTouch))       // If the dictionary doesn't have this touch
//        CFDictionarySetValue(touchDict, cfTouch, cfShape);
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (!touchArray[i].touch)
        {
            SAMTouchTrack* track = [[SAMTouchTrack alloc] init];
            touchArray[i] = track;
            touchArray[i].touch = touch;
            touchArray[i].parent = polygon;
            touchArray[i].child = subShape;
        }
    }
    
}

- (void)removeTouch:(UITouch *)touch
{
//    if (CFDictionaryContainsKey(touchDict, (__bridge const void *)touch))
//    {
//        //void* cfArray = [self getTouchClassArray:touch];
//        //free(cfArray);
//        CFDictionaryRemoveValue(touchDict, (__bridge const void *)touch);
//    }
    
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (touchArray[i].touch == touch)
        {
            touchArray[i] = NULL;
        }
    }
}

//- (NSArray *)getTouchClassArray:(UITouch *)touch
//{
//    const void* cfTouch = (__bridge const void *)touch;
//    if (CFDictionaryContainsKey(touchDict, cfTouch))
//    {
//        NSArray* shapeArray = (__bridge_transfer NSArray *)CFDictionaryGetValue(touchDict, cfTouch);
//        return shapeArray;
//    }
//    else
//        return nil;
//}

- (SAMTouchTrack *)getTouchClassArray:(UITouch *)touch
{
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (touchArray[i].touch == touch)
            return touchArray[i];
    }
    
    return nil;
}

- (BOOL)isInContainer:(UITouch *)touch
{
//    if (CFDictionaryContainsKey(touchDict, (__bridge const void *)(touch)))
//        return YES;
//    else
//        return NO;
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (touchArray[i].touch == touch)
            return YES;
    }
    
    return NO;
}

@end
