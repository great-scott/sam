//
//  SAMSpectrogramViewController.h
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SAMTouchTracker.h"

@interface SAMSpectrogramViewController : GLKViewController
{
    SAMTouchTracker* touchTracker;
}

@property BOOL editMode;
@property float redAmt;

- (void)pressHandle:(UILongPressGestureRecognizer *)sender;

@end
