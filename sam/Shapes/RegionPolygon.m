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
@synthesize grabPoint;
@synthesize circles;

- (id)initWithRect:(CGRect)boundsRect
{
    self = [super init];
    if (self)
    {
        initPositions[0] = GLKVector2Make(50, 50);
        initPositions[1] = GLKVector2Make(150, 50);
        initPositions[2] = GLKVector2Make(150, 150);
        initPositions[3] = GLKVector2Make(50, 150);
        
        lines = [[NSMutableArray alloc] init];
        circles = [[NSMutableArray alloc] init];
        polygon = nil;
        
        bounds = boundsRect;
        numVertices = MIN_VERTICES;
        [self setupShapes:numVertices];
    }
    
    return self;
}

- (void)setupShapes:(int)numberVertices;
{
    if ([lines count] != numberVertices)
    {
        [lines removeAllObjects];
        [circles removeAllObjects];
    }
    
    // Setup fill polygon
    if (polygon == nil)
        polygon = [[Shape alloc] init];
    
    polygon.bounds = bounds;
    polygon.color = GLKVector4Make(0.6, 0.6, 0.6, 0.4);     //TODO: make this dynamic
    polygon.numVertices = numberVertices;
    // Setup polygon vertex positions
    for (int i = 0; i < numberVertices; i++)
    {
        polygon.vertices[i] = initPositions[i];
        self.vertices[i] = initPositions[i];
    }
    
    // Setup Circles
    for (int i = 0; i < numberVertices; i++)
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
    for (int i = 0; i < numberVertices; i++)
    {
        Line *line = [[Line alloc] init];
        line.number = i;
        line.startPoint = initPositions[i];
        if (lineWrap == numberVertices)
            lineWrap = 0;
        
        line.endPoint = initPositions[lineWrap];
        lineWrap += 1;
        
        line.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
        line.bounds = bounds;
        
        [lines addObject:line];
    }
}


# pragma mark - Shape Object Checking -

- (BOOL)setPositionIfInside:(GLKVector2)press
{
    // Check if it's inside a circle first, then return if it is
    for (Ellipse *circle in self.circles)
    {
        if ([circle isInside:press])
        {
            [circle setPosition:press];
            // update vertices
            
            return YES;
        }
    }
    if ([self isInside:press shape:polygon])
    {
        [polygon setPosition:press];
        // update vertices
        
        return YES;
    }
    else
        return NO;
}

- (BOOL)isInside:(GLKVector2)newPosition shape:(Shape *)shape
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
        grabPoint = newPosition;
        return YES;
    }
    else
    {
        return NO;
    }
}


# pragma mark - Overidden Methods -

- (void)setPosition:(GLKVector2)newPosition
{
    // Position being set = know it's inside, but which?
    [self setPositionIfInside:newPosition];
}

- (GLKVector2)getPosition
{

}

- (void)setNumVertices:(int)numberVertices
{
    [self setupShapes:numberVertices];
}


#pragma mark - Methods -

- (void)addVertex:(GLKVector2)newPosition
{
    // Need to find which index the new position is between
    
    // Increment number of vertices
    numVertices += 1;
    polygon.numVertices += 1;
    polygon.vertices[numVertices - 1] = newPosition;
    
    Ellipse* circle = [[Ellipse alloc] init];
    circle.radiusX = CIRCLE_RADIUS;
    circle.radiusY = CIRCLE_RADIUS;
    circle.position = newPosition;
    circle.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
    circle.bounds = bounds;
    [circles addObject:circle];
    
    
}

#pragma mark - Render -
- (void)render
{
    [polygon render];
    [lines makeObjectsPerformSelector:@selector(render)];
    [circles makeObjectsPerformSelector:@selector(render)];
}

@end
