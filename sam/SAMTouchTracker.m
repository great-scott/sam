//
//  SAMTouchTracker.m
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMTouchTracker.h"
#import "SAMAudioModel.h"


@implementation SAMTouchTracker
@synthesize touchContainer;
@synthesize view;
@synthesize tapRecognizer;

- (id)init
{
    self = [super init];
    
    if (self)
    {   
        touchContainer = [[SAMTouchContainer alloc] init];
    }
    
    return self;
}


- (id)initWithRecogizer:(UITapGestureRecognizer *)recognizer
{
    self = [super init];
    
    if (self)
    {
        touchContainer = [[SAMTouchContainer alloc] init];
        tapRecognizer = recognizer;
    }
    
    return self;
}


#pragma mark - Touch Tracker Methods -

- (void)startTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{

    NSSet* beginTouches = [event allTouches];
    for (UITouch* touch in beginTouches)
    {
        CGPoint touchLocation = [touch locationInView:view];
        GLKVector2 press = GLKVector2Make(touchLocation.x, touchLocation.y);
        for (RegionPolygon* shape in shapes)
        {
            if (![touchContainer isInContainer:touch])
            {
                id obj = [shape isTouchInside:press];               // returns the object (aka part of regionPolygon that we touch
                if (obj != nil)
                {
                    [touchContainer addTouch:touch forParent:shape with:obj];
                }
            }
        }   
    }
}

- (void)moveTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    NSSet* movingTouches = [event allTouches];
    for (UITouch* touch in movingTouches)
    {
        CGPoint touchLocation = [touch locationInView:view];
        GLKVector2 press = GLKVector2Make(touchLocation.x, touchLocation.y);
        if ([touchContainer isInContainer:touch])
        {
            SAMTouchTrack* shapeTrack = [touchContainer getTouchClassArray:touch];
            RegionPolygon* polygon = shapeTrack.parent;
            
            [polygon setPosition:press withSubShape:shapeTrack.child];
        }
    }
}

- (void)endTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    if ([[event touchesForGestureRecognizer:tapRecognizer] count] > 0)
    {
        NSSet* endTouches = [event touchesForGestureRecognizer:tapRecognizer];
        for (UITouch* touch in endTouches)
        {
            if ([touchContainer isInContainer:touch])
                [touchContainer removeTouch:touch];
        }
    }
    
    NSSet* endTouches = [event allTouches];
    for (UITouch* touch in endTouches)
    {
        if ([touchContainer isInContainer:touch])
        {            
            [touchContainer removeTouch:touch];
        }
    }
}


# pragma mark - Gesture Callbacks -

- (void)removeTap:(UITouch *)touch
{
    [touchContainer removeTouch:touch];
}

- (void)handleTap:(UITapGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes
{
    CGPoint p = [sender locationInView:self.view];
    GLKVector2 tapPoint = GLKVector2Make(p.x, p.y);
    
    for (RegionPolygon* poly in shapes)
    {
        if ([poly isTouchInside:tapPoint])
        {
            if (poly.selected == NO)
                [poly setSelected:YES];
            else
                [poly setSelected:NO];
        }
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSMutableArray *toDelete = [NSMutableArray array];
        for (RegionPolygon* poly in shapes)
        {
            if (poly.selected == YES)
            {
                [toDelete addObject:poly];
                [[SAMAudioModel sharedAudioModel] removeShape:poly];
            }
        }
        
        [shapes removeObjectsInArray:toDelete];
    }
}


- (void)handleUpwardSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        for (RegionPolygon* poly in shapes)
        {
            if (poly.selected == YES)
            {
                poly.playMode = UPDOWN;
            }
        }
    }
}

- (void)handleBackwardSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        for (RegionPolygon* poly in shapes)
        {
            if (poly.selected == YES)
            {
                poly.playMode = REVERSE;
            }
        }
    }
}

- (void)handleForwardSwipe:(UISwipeGestureRecognizer *)sender withShapes:(NSMutableArray *)shapes
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        for (RegionPolygon* poly in shapes)
        {
            if (poly.selected == YES)
            {
                poly.playMode = FORWARD;
            }
        }
    }
}



@end






