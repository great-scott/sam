//
//  RegionPolygon.m
//  sam
//
//  Created by Scott McCoid on 1/14/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "RegionPolygon.h"


@implementation RegionPolygon
@synthesize bounds;

- (id)initWithRect:(CGRect)boundsRect
{
    self = [super init];
    if (self)
    {
        initPositions[0] = GLKVector2Make(50, 50);
        initPositions[1] = GLKVector2Make(150, 50);
        initPositions[2] = GLKVector2Make(150, 150);
        initPositions[3] = GLKVector2Make(50, 150);
        
        vertices = [[NSMutableArray alloc] init];
        lines = [[NSMutableArray alloc] init];
        circles = [[NSMutableArray alloc] init];
        
        bounds = boundsRect;
        numVertices = MIN_VERTICES;
        [self setupShapes];
    }
    
    return self;
}

- (void)setupShapes
{
    // Setup fill polygon
    polygon = [[Shape alloc] init];
    polygon.bounds = bounds;
    polygon.color = GLKVector4Make(0.6, 0.6, 0.6, 0.4);     //TODO: make this dynamic
    polygon.numVertices = numVertices;
    // Setup polygon vertex positions
    for (int i = 0; i < numVertices; i++)
    {
        polygon.vertices[i] = initPositions[i];
    }
    
    // Setup Circles
    for (int i = 0; i < numVertices; i++)
    {
        Ellipse* circle = [[Ellipse alloc] init];
        circle.radiusX = CIRCLE_RADIUS;
        circle.radiusY = CIRCLE_RADIUS;
        //circle.number = i;
        circle.position = initPositions[i];
        circle.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
        circle.bounds = bounds;
        [circles addObject:circle];
    }
    
    // Setup Lines
    int lineWrap = 1;
    
    // Create all lines first
    for (int i = 0; i < numVertices; i++)
    {
        Line *line = [[Line alloc] init];
        line.number = i;
        line.startPoint = initPositions[i];
        if (lineWrap == numVertices)
        {
            lineWrap = 0;
        }
        line.endPoint = initPositions[lineWrap];
        lineWrap += 1;
        
        line.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
        line.bounds = bounds;
        
        [lines addObject:line];
    }
}


# pragma mark - Overidden Methods -

- (void)setPosition:(GLKVector2)position
{
    
}

- (GLKVector2)getPosition
{

}


#pragma mark - Methods -

- (void)addVertex:(GLKVector2)position
{
    // Need to find which index the new position is between
    
}

#pragma mark - Render -
- (void)render
{
    [polygon render];
    [lines makeObjectsPerformSelector:@selector(render)];
    [circles makeObjectsPerformSelector:@selector(render)];
}

@end
