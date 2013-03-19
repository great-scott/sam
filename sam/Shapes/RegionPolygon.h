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

#define MIN_VERTICES 3
#define CIRCLE_RADIUS 5.0
#define FACE_LENGTH = 100.0

float getIntersectionPoint(Shape* polygon, int lineNumber, float xPosition);

typedef struct t_point_values
{
    float   top;
    float   bottom;
    
} POINT_VALUES;

typedef struct t_shape_points
{
    POINT_VALUES            points;
    struct SHAPE_POINTS     *nextPoint;
    
} SHAPE_POINTS; // aka node

@interface RegionPolygon : Shape
{
    NSMutableArray* lines;          // all the lines
    NSMutableArray* circles;        // all the circles on the vertices
    Shape*          polygon;        // general polygon
    
    GLKVector2 initPositions[4];
    
    SHAPE_POINTS*   shapePoints;    // 
}

@property int numVertices;
@property GLKVector4 color;         // Different parts have a different color relationship and will change on their own
@property GLKVector4 boundPoints;
@property (nonatomic, strong) NSMutableArray* circles;
@property int stftLength;           // set this property when instantiated

- (id)initWithRect:(CGRect)bounds;
- (void)addVertex:(GLKVector2)newPosition;
- (id)isTouchInside:(GLKVector2)press;
- (void)setPosition:(GLKVector2)newPosition withSubShape:(id)shape;
- (int)isTouchingLine:(GLKVector2)currentPosition;

// get begin and end
// find top and bottom
// need method for 

@end
