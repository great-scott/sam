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
#import "RegionPolygon.h"
#import "SAMAudioModel.h"
#import "SAMSpectrogramViewController.h"
#import "SAMGestureViewController.h"

@interface SAMEditViewController : GLKViewController
{
    NSMutableArray* shapes;
    SAMTouchTracker* touchTracker;
    SAMSpectrogramViewController* spectroViewControl;
    EAGLContext*    context;
    
    RegionPolygon* newMovingShape;
}

@property (nonatomic, strong) SAMSpectrogramViewController* spectroViewControl;
@property (strong, nonatomic) EAGLContext* context;
@property (nonatomic, strong) UIView* spectroView;

- (IBAction)handleTap:(UITapGestureRecognizer *)sender;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleForwardSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleBackwardSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleUpwardSwipe:(UISwipeGestureRecognizer *)sender;

- (RegionPolygon *)addSquare:(GLKVector2)location;
- (RegionPolygon *)addTriangle:(GLKVector2)location;
- (void)addSpectrogramView;


@end
