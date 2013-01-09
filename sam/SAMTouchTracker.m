//
//  SAMTouchTracker.m
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMTouchTracker.h"


@implementation SAMTouchTracker
@synthesize touchContainer;
@synthesize view;

- (id)init
{
    self = [super init];
    
    if (self)
    {   
        touchContainer = [[SAMTouchContainer alloc] init];
    }
    
    return self;
}


#pragma mark - Touch Tracker Methods -

- (void)startTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    NSSet* beginTouches = [event allTouches];
    for (UITouch* touch in beginTouches)
    {
        for (RegionSquare* square in shapes)
        {
            if (![touchContainer isInContainer:touch])
            {
                Shape* s = [self isTouch:touch inside:square];
                if (s != nil)
                    [touchContainer addTouch:touch with:s];
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
            const void* cfObject = [touchContainer getTouchClassArray:touch];
            Shape* storedShape = (__bridge Shape *)cfObject;            
            storedShape.position = press;
        }
    }
}

- (void)endTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    NSSet* endTouches = [event allTouches];
    for (UITouch* touch in endTouches)
    {
        if ([touchContainer isInContainer:touch])
            [touchContainer removeTouch:touch];
    }
}


# pragma mark - Shape Object Checking -

- (Shape *)isTouch:(UITouch *)touch inside:(RegionSquare *)square
{
    CGPoint touchLocation = [touch locationInView:view];
    GLKVector2 press = GLKVector2Make(touchLocation.x, touchLocation.y);
    
    // Check if it's inside a circle first, then return if it is
    for (Ellipse *circle in square.vertexCircles)
    {
        if ([circle isInside:press])
        {
            NSLog(@"Touched Circle");
            return circle;
        }
    }
    
    if ([self isInside:press shape:square])
    {
        NSLog(@"Touched Inside Square");
        return square;
    }

    return nil;
    
    //    int touchingLine = [self isTouchingLine:press];
    //    if (touchingLine >= 0)
    //    {
    //        insideLine = YES;
    //        const void *cfTouch = (__bridge const void *)_touch;
    //        const void *cfLine = (__bridge const void *)[lines objectAtIndex:touchingLine];
    //
    //        CFDictionarySetValue(_lineDict, cfTouch, cfLine);
    //        self.stillInside = YES;
    //        return YES;
    //    }
    
}

- (BOOL)isInside:(GLKVector2)position shape:(RegionSquare *)square
{
    int i = 0;
    int j = square.numVertices - 1;
    int inside = 0;

    for (i = 0, j = square.numVertices - 1; i < square.numVertices; j = i++)
    {
        if ((((square.vertexArray[i].position.y <= position.y) &&
              (position.y < square.vertexArray[j].position.y)) ||
             ((square.vertexArray[j].position.y <= position.y) &&
              (position.y < square.vertexArray[i].position.y))) &&
            (position.x < (square.vertexArray[j].position.x - square.vertexArray[i].position.x)
             * (position.y - square.vertexArray[i].position.y) / (square.vertexArray[j].position.y - square.vertexArray[i].position.y) + square.vertexArray[i].position.x))

            inside = !inside;
    };

    if (inside == 1)
    {
        square.grabPoint = position;
        return YES;
    }
    else
    {
        return NO;
    }
}

//- (int)isTouchingLine:(GLKVector2)_position
//{
//    BOOL equal = NO;
//    int numLines = [lines count];
//    
//    for (int i = 0; i < numLines; i++)
//    {
//        Line* l = [lines objectAtIndex:i];
//        
//        float e_y = l.endPoint.y;
//        float s_y = l.startPoint.y;
//        float diffY = e_y - s_y;
//        
//        float e_x = l.endPoint.x;
//        float s_x = l.startPoint.x;
//        float diffX = e_x - s_x;
//        
//        if (diffY == 0)
//        {
//            if (_position.y <= e_y + 10 && _position.y >= e_y - 10)
//            {
//                grabPoint = _position;
//                return i;
//            }
//        }
//        else if (diffX == 0)
//        {
//            if (_position.x <= e_x + 10 && _position.x >= e_x - 10)
//            {
//                grabPoint = _position;
//                return i;
//            }
//        }
//        else
//        {
//            float m = diffY / diffX;
//            float b = l.startPoint.y - m * l.startPoint.x;
//            
//            float newPoint = _position.y - m * _position.x;
//            
//            if (newPoint <= b + 25 && newPoint >= b - 25)
//            {
//                equal = YES;
//                grabPoint = _position;
//                return i;
//            }
//        }
//    }
//    
//    return -1;
//}


@end
