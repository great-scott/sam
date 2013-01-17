//
//  SAMGestureViewController.h
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTouchTracker.h"

@interface SAMGestureViewController : UIViewController
{
    SAMTouchTracker* touchTracker;
}

- (IBAction)pressHandle:(UILongPressGestureRecognizer *)sender;

@end
