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
}

@property (nonatomic, strong) SAMSpectrogramViewController* spectroViewControl;
@property (nonatomic, strong) SAMGestureViewController* gestureViewControl;

@property (nonatomic, strong) UIView* spectroView;
@property (nonatomic, strong) UIView* gestureView;
- (IBAction)handlePress:(UILongPressGestureRecognizer *)sender;

- (void)addSquare;
- (void)addTriangle;
- (void)addSpectrogram;

@end
