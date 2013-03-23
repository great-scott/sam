//
//  RegionPolygon.h
//  sam
//
//  Created by Scott McCoid on 1/14/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "Shape.h"
#import "Ellipse.h"
#import "Line.h"
#import "Rectangle.h"
#import "SAMLinkedList.h"

#define MIN_VERTICES 3
#define CIRCLE_RADIUS 6.0
#define FACE_LENGTH 100.0
#define LINE_WIDTH 4.0

//float getIntersectionPoint(Shape* polygon, int lineNumber, float xPosition);

@interface RegionPolygon : Shape
{
    NSMutableArray* lines;          // all the lines
    NSMutableArray* circles;        // all the circles on the vertices
    Shape*          polygon;        // general polygon
    
    GLKVector2 initPositions[4];
    
    SAMLinkedList*   pointList;     //
    
    GLKVector4 kDefaultColor;
    GLKVector4 kSelectColor;
    GLKVector4 kCircleDefaultColor;
    GLKVector4 kLineDefaultColor;
}

@property int numVertices;
@property GLKVector4 color;         // Different parts have a different color relationship and will change on their own
@property GLKVector4 boundPoints;
@property (nonatomic, strong) NSMutableArray* circles;
@property int stftLength;           // set this property when instantiated
@property int begin;
@property int end;
@property BOOL selected;
@property (nonatomic, strong) SAMLinkedList* pointList;

- (id)initWithRect:(CGRect)bounds;
- (void)addVertex:(GLKVector2)newPosition;
- (id)isTouchInside:(GLKVector2)press;
- (void)setPosition:(GLKVector2)newPosition withSubShape:(id)shape;
- (int)isTouchingLine:(GLKVector2)currentPosition;

// intersection methods
- (void)updateIntersectList;
- (void)findTopAndBottom:(float)xPosition top:(double *)top bottom:(double *)bottom;
- (BOOL)inSegment:(GLKVector2)segment with:(float)point;
- (float)getIntersectionPoint:(float)xPosition with:(int)lineNumber;
+ (void)changeTouchYScale:(double *)inputPoint;

@end
