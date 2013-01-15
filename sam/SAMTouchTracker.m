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
        for (RegionPolygon* shape in shapes)
        {
            if (![touchContainer isInContainer:touch])
            {
                if ([self isTouch:touch inside:shape])
                    [touchContainer addTouch:touch with:shape];
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
            RegionPolygon* storedShape = (__bridge RegionPolygon *)cfObject;
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

- (BOOL)isTouch:(UITouch *)touch inside:(RegionPolygon *)shape
{
    CGPoint touchLocation = [touch locationInView:view];
    GLKVector2 press = GLKVector2Make(touchLocation.x, touchLocation.y);
    
    // Check if it's inside a circle first, then return if it is
    for (Ellipse *circle in shape.circles)
    {
        if ([circle isInside:press])
        {
            NSLog(@"Touched Circle");
            return YES;
        }
    }
    
    if ([self isInside:press shape:shape])
    {
        NSLog(@"Touched Inside Square");
        return YES;
    }

    return NO;
    
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

- (BOOL)isInside:(GLKVector2)newPosition shape:(RegionPolygon *)shape
{
    int i = 0;
    int j = shape.numVertices - 1;
    int inside = 0;

    for (i = 0, j = shape.numVertices - 1; i < shape.numVertices; j = i++)
    {
        if ((((shape.vertices[i].y <= newPosition.y) &&
              (newPosition.y < shape.vertices[j].y)) ||
             ((shape.vertices[j].y <= newPosition.y) &&
              (newPosition.y < shape.vertices[i].y))) &&
            (newPosition.x < (shape.vertices[j].x - shape.vertices[i].x)
             * (newPosition.y - shape.vertices[i].y) / (shape.vertices[j].y - shape.vertices[i].y) + shape.vertices[i].x))

            inside = !inside;
    };

    if (inside == 1)
    {
        shape.grabPoint = newPosition;
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
