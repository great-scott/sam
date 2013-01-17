//
//  SAMTouchContainer.h
//  sam
//
//  Created by Scott McCoid on 1/9/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//
//  This is a somewhat generic container for touches.
//  It stores the touch as a void* in a dictionary to keep track of the
//  throughout its lifecycle, and the object/class associated with the touch.
//  This is useful for the determining which of the parts of an object the
//  touch - touches.

#import <Foundation/Foundation.h>
#import "SAMTouchTrack.h"

#define MAX_TOUCHES 5

@interface SAMTouchContainer : NSObject
{
    CFMutableDictionaryRef touchDict;
    SAMTouchTrack* touchArray[MAX_TOUCHES];
}

//- (void)addTouch:(UITouch *)touch with:(id)object;
- (BOOL)addTouch:(UITouch *)touch forParent:(id)polygon with:(id)object;
- (void)removeTouch:(UITouch *)touch;

- (SAMTouchTrack *)getTouchClassArray:(UITouch *)touch;
- (BOOL)isInContainer:(UITouch *)touch;

@end
