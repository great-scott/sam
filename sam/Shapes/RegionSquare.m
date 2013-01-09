//
//  RegionSquare.m
//  TRE
//
//  Created by Scott McCoid on 10/16/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "RegionSquare.h"
#define WIDTH 100.0
#define HEIGHT 100.0

@implementation RegionSquare
@synthesize vertexCircles;
@synthesize stillInside;
@synthesize shapeColor;
@synthesize grabPoint;
@synthesize touchLine;
@synthesize vertexArray;

- (id)initWithRect:(CGRect)bounds
{
    self = [super init];
    if (self)
    {
        CGFloat screenWidth = bounds.size.width;
        CGFloat screenHeight = bounds.size.height;
        
        // Set initial vertices 
        vertices[0].position = GLKVector2Make(0, HEIGHT);
        vertices[1].position = GLKVector2Make(WIDTH, HEIGHT);
        vertices[2].position = GLKVector2Make(WIDTH, 0);
        vertices[3].position = GLKVector2Make(0, 0);
        
        // Setup pointer for first point in array;
        vertexArray = &vertices[0];
        
        // set initial centroid value
        centroid = GLKVector2Make(WIDTH / 2.0, HEIGHT / 2.0);
        
        // Create line and circle arrays
        lines = [[NSMutableArray alloc] init];
        circles = [[NSMutableArray alloc] init];
        
        fillRect = [[Rectangle alloc] init];
        fillRect.left = 0.0;
        fillRect.top = 0.0;
        fillRect.right = screenWidth;
        fillRect.bottom = screenHeight;
        
        fillRect.color = GLKVector4Make(0.6, 0.6, 0.6, 0.4);
        
        for (int i = 0; i < self.numVertices; i++)
        {
            [fillRect setVertexPosition:i forPosition:vertices[i].position];
        }
        
        
        int lineWrap = 1;
        
        // Create all lines first
        for (int i = 0; i < self.numVertices; i++)
        {
            Line *line = [[Line alloc] init];
            line.number = i;
            line.startPoint = vertices[i].position;
            if (lineWrap == self.numVertices)
            {
                lineWrap = 0;
            }
            line.endPoint = vertices[lineWrap].position;
            lineWrap += 1;
            
            line.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
            
            line.left = 0.0;
            line.top = 0.0;
            line.right = screenWidth;
            line.bottom = screenHeight;
            
            [lines addObject:line];
        }
        
        // Now create circles
        for (int i = 0; i < self.numVertices; i++)
        {
            Ellipse *circle = [[Ellipse alloc] init];
            circle.radiusX = 5.0;
            circle.radiusY = 5.0;
            circle.number = i;
            circle.position = vertices[i].position;
            
            circle.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
    
            circle.left = 0.0;
            circle.top = 0.0;
            circle.bottom = screenHeight;
            circle.right = screenWidth;
            
            [circles addObject:circle];
        }
        
        // Create readonly array for the vertex circles
        vertexCircles = [[NSArray alloc] initWithArray:circles];
    }
    
    return self;
}


- (void)updatePositionVectors
{
    int lineWrap = 1;
    
    for (int i = 0; i < self.numVertices; i++)
    {
        Line *l = [lines objectAtIndex:i];
        l.startPoint = vertices[i].position;
        if (lineWrap == self.numVertices)
        {
            lineWrap = 0;
        }
        l.endPoint = vertices[lineWrap].position;
        lineWrap += 1;
        
        Ellipse *c = [circles objectAtIndex:i];
        c.position = vertices[i].position;
    }
    
    //[[TREAudioModel sharedAudioModel] setBounds:[self getSideBounds] andRight:[self getVerticalBounds]];

}

- (GLKVector2)getSideBounds
{
    float left = 9999.0;
    float right = 0.0;
    
    for (int i = 0; i < self.numVertices; i++)
    {
        if (vertices[i].position.x < left)
            left = vertices[i].position.x;
        if (vertices[i].position.x > right)
            right = vertices[i].position.x;
    }
    
    return GLKVector2Make(left, right);
}

- (GLKVector2)getVerticalBounds
{
    float top = 9999.0;
    float bottom = 0.0;
    
    for (int i = 0; i < self.numVertices; i++)
    {
        if (vertices[i].position.y < top)
            top = vertices[i].position.y;
        if (vertices[i].position.y > bottom)
            bottom = vertices[i].position.y;
    }
    
    return GLKVector2Make(top, bottom);
}

- (BOOL)isInside:(GLKVector2)_position
{
    int i = 0;
    int j = self.numVertices - 1;
    int inside = 0;
    
    for (i = 0, j = self.numVertices - 1; i < self.numVertices; j = i++)
    {
        if ((((vertices[i].position.y <= _position.y) && 
               (_position.y < vertices[j].position.y)) ||
              ((vertices[j].position.y <= _position.y) &&
               (_position.y < vertices[i].position.y))) &&
               (_position.x < (vertices[j].position.x - vertices[i].position.x)
                * (_position.y - vertices[i].position.y) / (vertices[j].position.y - vertices[i].position.y) + vertices[i].position.x))
              
              inside = !inside;
    };
    
    if (inside == 1)
    {   
        grabPoint = _position;
        return YES;
    }
    else
    {
        return NO;
    }
}


- (int)isTouchingLine:(GLKVector2)_position
{
    BOOL equal = NO;
    int numLines = [lines count];
        
    for (int i = 0; i < numLines; i++)
    {
        Line* l = [lines objectAtIndex:i];
        
        float e_y = l.endPoint.y;
        float s_y = l.startPoint.y;
        float diffY = e_y - s_y;

        float e_x = l.endPoint.x;
        float s_x = l.startPoint.x;
        float diffX = e_x - s_x;
        
        if (diffY == 0)
        {
            if (_position.y <= e_y + 10 && _position.y >= e_y - 10)
            {
                grabPoint = _position;
                return i;
            }
        }
        else if (diffX == 0)
        {
            if (_position.x <= e_x + 10 && _position.x >= e_x - 10)
            {
                grabPoint = _position;
                return i;
            }
        }
        else
        {
            float m = diffY / diffX;
            float b = l.startPoint.y - m * l.startPoint.x;
        
            float newPoint = _position.y - m * _position.x;
        
            if (newPoint <= b + 25 && newPoint >= b - 25)
            {
                equal = YES;
                grabPoint = _position;
                return i;
            }
        }
    }
    
    return -1;
}


/*
 *  This function takes in the touch and determines if it's inside a vertex or the main body of the square.
 *  If it's inside either it assigns the touch pointer to the appropriate dictionary. The function returns 
 *  YES if it's in either and NO if it is not in either.
 */
- (BOOL)isInside:(UITouch *)_touch givenCorners:(CFMutableDictionaryRef)_touchDict andArea:(CFMutableDictionaryRef)_squareDict andLines:(CFMutableDictionaryRef)_lineDict andView:(UIView *)_view
{
    CGPoint touchLocation = [_touch locationInView:_view];
    GLKVector2 press = GLKVector2Make(touchLocation.x, touchLocation.y + 20.0);
    
    BOOL insideCircle = NO;
    BOOL insideSquare = NO;
    BOOL insideLine = NO;
    
    // Check if it's inside a circle first, then return if it is (want larger area for a vertex selection
    for (Ellipse *c in self.vertexCircles)
    {
        if ([c isInside:press])
        {
            const void *cfTouch = (__bridge const void *)_touch;
            const void *cfCircle = (__bridge const void *)c;
            
            CFDictionarySetValue(_touchDict, cfTouch, cfCircle);                
            c.stillInside = YES;
            insideCircle = YES;
        }
    }
    if (insideCircle == YES)
    {
        return YES;
    }
    
    int touchingLine = [self isTouchingLine:press];
    if (touchingLine >= 0)
    {        
        insideLine = YES;
        const void *cfTouch = (__bridge const void *)_touch;
        const void *cfLine = (__bridge const void *)[lines objectAtIndex:touchingLine];
        
        CFDictionarySetValue(_lineDict, cfTouch, cfLine);
        self.stillInside = YES;
        return YES;
    }
    else if ([self isInside:press])
    {
        insideSquare = YES;
        const void *cfTouch = (__bridge const void *)_touch;
        const void *cfSquare = (__bridge const void *)self;
        
        CFDictionarySetValue(_squareDict, cfTouch, cfSquare);
        self.stillInside = YES;
        return YES;
    }
    else 
    {
        return NO;
    }
    
}


- (void)setPosition:(GLKVector2)_newPosition
{
    GLKVector2 differenceOfPositions = GLKVector2Subtract(_newPosition, grabPoint);
    
    for (int i = 0; i < self.numVertices; i++)
    {
        vertices[i].position = GLKVector2Add(vertices[i].position, differenceOfPositions);
        [fillRect setVertexPosition:i forPosition:vertices[i].position];
    }
    
    [self updatePositionVectors];
    
    position = GLKVector2Add(differenceOfPositions, position);
    grabPoint = GLKVector2Add(differenceOfPositions, grabPoint);
}

- (void)setVertexPosition:(int)index forPosition:(GLKVector2)_newPosition
{
    if (index < self.numVertices)
    {
        vertices[index].position = _newPosition;
        [fillRect setVertexPosition:index forPosition:_newPosition];
    }
    
    [self updatePositionVectors];
}

- (void)setLinePosition:(int)index forPosition:(GLKVector2)_newPosition
{
    GLKVector2 differenceOfPositions = GLKVector2Subtract(_newPosition, grabPoint);

    if (index < [lines count])
    {
        //Line* l = [lines objectAtIndex:index];
        
        switch (index) 
        {
            case 0:
                vertices[0].position = GLKVector2Add(vertices[0].position, differenceOfPositions);
                vertices[1].position = GLKVector2Add(vertices[1].position, differenceOfPositions);
                break;
            case 1:
                vertices[1].position = GLKVector2Add(vertices[1].position, differenceOfPositions);
                vertices[2].position = GLKVector2Add(vertices[2].position, differenceOfPositions);
                break;
            case 2:
                vertices[2].position = GLKVector2Add(vertices[2].position, differenceOfPositions);
                vertices[3].position = GLKVector2Add(vertices[3].position, differenceOfPositions);
                break;
            case 3:
                vertices[3].position = GLKVector2Add(vertices[3].position, differenceOfPositions);
                vertices[0].position = GLKVector2Add(vertices[0].position, differenceOfPositions);
                break;
            default:
                break;
        }
        
        //l.startPoint = GLKVector2Add(l.startPoint, differenceOfPositions);
        //l.endPoint = GLKVector2Add(l.endPoint, differenceOfPositions);
    }
    
    [self updatePositionVectors];
    
    grabPoint = GLKVector2Add(differenceOfPositions, grabPoint);
}


- (int)numVertices
{
    return 4;
}

- (void)render
{
    [fillRect render];
    [lines makeObjectsPerformSelector:@selector(render)];
    [circles makeObjectsPerformSelector:@selector(render)];
}

@end
