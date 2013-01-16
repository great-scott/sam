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

- (void)updateLines
{
    // Setup Lines
    int lineWrap = 1;
    
    // update the line positions
    for (int i = 0; i < numVertices; i++)
    {
        Line *line = [lines objectAtIndex:i];
        line.startPoint = self.vertices[i];
        if (lineWrap == numVertices)
            lineWrap = 0;
        
        line.endPoint = self.vertices[lineWrap];
        lineWrap += 1;
    }
}


# pragma mark - Shape Object Checking -

- (void)setPosition:(GLKVector2)newPosition withSubShape:(id)shape
{
    GLKVector2 differenceOfPositions = GLKVector2Subtract(newPosition, grabPoint);
    
    // Check if sub shape is a circle or not
    if ([shape isMemberOfClass:[Ellipse class]])
    {
        Ellipse* newShape = (Ellipse *)shape;
        newShape.position = newPosition;
        
        for (int i = 0; i < numVertices; i++)
        {
            Ellipse* circle = [circles objectAtIndex:i];
            self.vertices[i] = circle.position;
            polygon.vertices[i] = self.vertices[i];
        }
        
        [self updateLines];
        
    }
    else if ([shape isKindOfClass:[Shape class]]) // if we touched inside
    {
        // update the circle positions
        for (int i = 0; i < numVertices; i++)
        {
            Ellipse* circle = [circles objectAtIndex:i];
            self.vertices[i] = GLKVector2Add(self.vertices[i], differenceOfPositions);
            circle.position = self.vertices[i];
            polygon.vertices[i] = self.vertices[i];
        }
        
        [self updateLines];
        
        position = GLKVector2Add(differenceOfPositions, position);
        grabPoint = GLKVector2Add(differenceOfPositions, grabPoint);
        
    }
}

- (BOOL)isInsidePolygon:(GLKVector2)newPosition
{
    int i = 0;
    int j = numVertices - 1;
    int inside = 0;
    
    for (i = 0, j = numVertices - 1; i < numVertices; j = i++)
    {
        if ((((self.vertices[i].y <= newPosition.y) &&
              (newPosition.y < self.vertices[j].y)) ||
             ((self.vertices[j].y <= newPosition.y) &&
              (newPosition.y < self.vertices[i].y))) &&
            (newPosition.x < (self.vertices[j].x - self.vertices[i].x)
             * (newPosition.y - self.vertices[i].y) / (self.vertices[j].y - self.vertices[i].y) + self.vertices[i].x))
            
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

//- (BOOL)isTouch:(GLKVector2)press inside:(RegionPolygon *)shape
- (id)isTouchInside:(GLKVector2)press
{    
    // Check if it's inside a circle first, then return if it is
    for (Ellipse *circle in self.circles)
    {
        if ([circle isInside:press])
            return circle;
    }
    
    if ([self isInsidePolygon:press])
        return polygon;
    else
        return nil;
}


# pragma mark - Overidden Methods -

- (void)setNumVertices:(int)numberVertices
{
    [self setupShapes:numberVertices];
    numVertices = numberVertices;
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
