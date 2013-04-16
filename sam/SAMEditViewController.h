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
#import "SAMGestureRecognizers.h"


@interface SAMEditViewController : GLKViewController <SAMTapGestureRecognizerDelegate>
{
    NSMutableArray* shapes;
    SAMTouchTracker* touchTracker;
    SAMSpectrogramViewController* spectroViewControl;
    EAGLContext*    context;
    
    RegionPolygon* newMovingShape;
}

@property (nonatomic, strong) SAMSpectrogramViewController* spectroViewControl;
@property (nonatomic, strong) EAGLContext* context;
@property (nonatomic, strong) UIView* spectroView;
@property (nonatomic, strong) SAMTapGestureRecognizer* tapRecognizer;


- (void)handleTap:(UITapGestureRecognizer *)sender;
- (void)removeTap:(UITouch *)touch;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleForwardSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleBackwardSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleUpwardSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleDownwardSwipe:(UISwipeGestureRecognizer *)sender;

- (void)addSquare:(GLKVector2)location;
- (void)addTriangle:(GLKVector2)location;
- (void)addPentagon:(GLKVector2)location;
- (void)addHexagon:(GLKVector2)location;

- (void)addSpectrogramView;

- (void)rateChanged:(UISegmentedControl *)sender;

@end
