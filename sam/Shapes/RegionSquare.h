//
//  RegionSquare.h
//  TRE
//
//  Created by Scott McCoid on 10/16/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "Shape.h"
#import "Line.h"
#import "Ellipse.h"
#import "Rectangle.h"


typedef struct 
{
    GLKVector2 position;
    GLKVector4 color;
} Vertex;


@interface RegionSquare : Shape
{
    NSMutableArray *lines;
    NSMutableArray *circles;
    
    BOOL stillInside;
    GLKVector2 centroid;
    GLKVector2 grabPoint;
    Rectangle *fillRect;
    
    Vertex vertices[4];
    int touchLine;
}

@property (readonly) NSArray *vertexCircles;
@property BOOL stillInside;
@property GLKVector4 shapeColor;
@property GLKVector2 grabPoint;
@property int touchLine;
@property Vertex* vertexArray;

- (void)setVertexPosition:(int)index forPosition:(GLKVector2)position;
- (BOOL)isInside:(GLKVector2)_position;
- (id)initWithRect:(CGRect)bounds;
- (BOOL)isInside:(UITouch *)_touch givenCorners:(CFMutableDictionaryRef)_touchDict andArea:(CFMutableDictionaryRef)_squareDict andLines:(CFMutableDictionaryRef)_lineDict andView:(UIView *)_view;
- (int)isTouchingLine:(GLKVector2)_position;
- (void)setLinePosition:(int)index forPosition:(GLKVector2)_newPosition;

@end
