//
//  SAMEditViewController.h
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "RegionSquare.h"
#import "SAMTouchTracker.h"

@interface SAMEditViewController : GLKViewController
{
    NSMutableArray* squares;
    SAMTouchTracker* touchTracker;
}

- (void)addSquare;

@end
