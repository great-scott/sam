//
//  SAMTouchTracker.h
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//
//  This class is tied heavily to the regionSquare / polygon stuff

#import <Foundation/Foundation.h>
#import "SAMTouchContainer.h"
#import "RegionPolygon.h"

@interface SAMTouchTracker : NSObject
{
    NSTimeInterval timeStamp;
    NSTimeInterval prevTimeStamp;
}

@property (nonatomic, strong) SAMTouchContainer* touchContainer;
@property (nonatomic, strong) UIView* view;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;

- (id)initWithRecogizer:(UITapGestureRecognizer *)recognizer;

- (void)startTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
- (void)moveTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
- (void)endTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
// gesture handlers
- (void)handleUpwardSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes;
- (void)handleBackwardSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes;
- (void)handleForwardSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes;
- (void)handleSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes;
- (void)handleTap:(UITapGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes;
- (void)removeTap:(UITouch *)touch;

@end
