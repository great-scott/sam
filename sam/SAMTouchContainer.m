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

- (BOOL)addTouch:(UITouch *)touch forParent:(id)polygon with:(id)subShape
{
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (!touchArray[i].touch)
        {
            SAMTouchTrack* track = [[SAMTouchTrack alloc] init];
            touchArray[i] = track;
            touchArray[i].touch = touch;
            touchArray[i].parent = polygon;
            touchArray[i].child = subShape;
            return YES;
        }
    }
    
    return NO;
    
}

- (void)removeTouch:(UITouch *)touch
{
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (touchArray[i].touch == touch)
        {
            touchArray[i] = NULL;
        }
    }
}

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
    for (int i = 0; i < MAX_TOUCHES; i++)
    {
        if (touchArray[i].touch == touch)
            return YES;
    }
    
    return NO;
}

@end
