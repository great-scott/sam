//
//  SAMTouchContainer.h
//  sam
//
//  Created by Scott McCoid on 1/9/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMTouchContainer : NSObject
{
    CFMutableDictionaryRef touchDict;
}

- (void)addTouch:(UITouch *)touch with:(id)object;
- (const void *)getTouch:(UITouch *)touch;

@end
