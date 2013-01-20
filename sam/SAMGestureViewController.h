//
//  SAMGestureViewController.h
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTouchTracker.h"
#import "SAMSpectrogramViewController.h"

@interface SAMGestureViewController : UIViewController
{
    SAMTouchTracker* touchTracker;
}

@property BOOL editMode;
@property (nonatomic, strong) SAMSpectrogramViewController* spectroViewController;

- (IBAction)pressHandle:(UILongPressGestureRecognizer *)sender;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)handlePan:(UIPanGestureRecognizer *)sender;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;

@end
