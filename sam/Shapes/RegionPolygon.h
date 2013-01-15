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

@interface RegionPolygon : Shape
{
    //NSMutableArray* vertices;       // all the vertex...do I even need this?
    NSMutableArray* lines;          // all the lines
    NSMutableArray* circles;        // all the circles on the vertices
    Shape*          polygon;        // general polygon
    
    GLKVector2 grabpoint;
    GLKVector2 initPositions[4];
}

@property int numVertices;
@property GLKVector4 color;         // Different parts have a different color relationship and will change on their own
@property (nonatomic, strong) NSMutableArray* circles;
@property GLKVector2 grabPoint;

- (id)initWithRect:(CGRect)bounds;
- (void)addVertex:(GLKVector2)newPosition;

@end
