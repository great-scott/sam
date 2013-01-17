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

@interface SAMEditViewController : GLKViewController
{
    NSMutableArray* shapes;
    SAMTouchTracker* touchTracker;
}

@property (nonatomic, strong) SAMSpectrogramViewController* spectroViewControl;

@property (nonatomic, strong) UIView* spectroView;

- (void)addSquare;
- (void)addTriangle;
- (void)addSpectrogram;

@end
