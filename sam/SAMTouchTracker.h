//
//  SAMTouchTracker.h
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMTouchTracker : NSObject
{
    CFMutableDictionaryRef touchDict;
}

- (void)addTouch:(UITouch *)touch with:(id)object;
- (id)getTouch:(UITouch *)touch;

@end
