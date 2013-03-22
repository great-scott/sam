//
//  RegionPolygon.m
//  sam
//
//  Created by Scott McCoid on 1/14/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "RegionPolygon.h"
#import "SAMAudioModel.h"

#define PI 3.14159265

@implementation RegionPolygon
@synthesize bounds;
@synthesize grabPoint;
@synthesize circles;
@synthesize boundPoints;

@synthesize stftLength;     // the same as the stft's size
@synthesize begin;          // scaled bound points
@synthesize end;
@synthesize pointList;


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
        
        pointList = [[SAMLinkedList alloc] init];
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
    polygon.color = GLKVector4Make(0.5, 0.5, 0.5, 0.7);     //TODO: make this dynamic
    polygon.numVertices = numberVertices;
    polygon.useConstantColor = YES;
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
        circle.number = i;
        circle.position = initPositions[i];
        circle.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
        circle.bounds = bounds;
        circle.useConstantColor = YES;
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
        line.useConstantColor = YES;
        
        [lines addObject:line];
    }
    
    [self findBoundPoints];
}

- (void)updateLines
{
    // Setup Lines
    int lineWrap = 1;
    
    // update the line positions
    for (int i = 0; i < numVertices; i++)
    {
        if (numVertices > [lines count])
        {
            Line* l = [[Line alloc] init];
            [lines addObject:l];
        }
        
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
    
    [self findBoundPoints];
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

- (void)findBoundPoints
{
    float leftMost = -1;
    float rightMost = -1;
    float topMost = -1;
    float bottomMost = -1;
    for (int i = 0; i < numVertices; i++)
    {
        if (leftMost == -1 || self.vertices[i].x < leftMost)
        {
            leftMost = self.vertices[i].x;
            if (leftMost < 0)
                leftMost = 0;
        }
        if (rightMost == -1 || self.vertices[i].x > rightMost)
        {
            rightMost = self.vertices[i].x;
            if (rightMost > bounds.size.width)
                rightMost = bounds.size.width;
        }
        if (topMost == -1 || bounds.size.height - self.vertices[i].y > topMost)
        {
            // Need to invert values
            topMost = bounds.size.height - self.vertices[i].y;
            if (topMost > bounds.size.height)
                topMost = bounds.size.height;
        }
        if (bottomMost == -1 || bounds.size.height - self.vertices[i].y < bottomMost)
        {
            // Need to invert values
            bottomMost = bounds.size.height - self.vertices[i].y;
            if (bottomMost < 0)
                bottomMost = 0;
        }
    }
    
    boundPoints = GLKVector4Make(leftMost, rightMost, topMost, bottomMost);
    
    if (stftLength > 0)
    {
        begin = floor(stftLength / [SAMAudioModel sharedAudioModel].editArea.size.width * leftMost);
        end = ceil(stftLength / [SAMAudioModel sharedAudioModel].editArea.size.width * rightMost);
        
        [self updateIntersectList];
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

- (GLKVector2)findCentroid
{
    float xSum = 0;
    float ySum = 0;
    for (int i = 0; i < numVertices; i++)
    {
        xSum += polygon.vertices[i].x;
        ySum += polygon.vertices[i].y;
    }
    
    return GLKVector2Make(xSum / numVertices, ySum / numVertices);
}


# pragma mark - Intersection Methods -

- (void)updateIntersectList
{
    int length = end - begin;
    float xCoord;
    
    // just do this the first time
    if (pointList.length == 0)
    {
        // clear point list
        //[pointList clear];
        
        // repopulate it, this is very 'dumb' and brute-force
        for (int i = 0; i < length; i++)
        {
            DATA* pointData = [self createAndFindPointData:i];
            [pointList append:pointData];
        }
        
        // check if the cursor is out of bounds, then reset if it is.
        // [pointList cursorCheck];
        
        // only happens the first time we're adding points
        [SAMAudioModel sharedAudioModel].numberOfVoices++;
    }
    else
    {
        // do we have points before tail now?
        if (begin < pointList.tail->data->x)
        {
            int diff = pointList.tail->data->x - begin;
            for (int i = diff - 1; i >= 0; i--)
            {
                DATA* pointData = [self createAndFindPointData:i];
                [pointList insert:pointData at:i];
            }
        }
        
        if (end > pointList.head->data->x)
        {
            int diff = end - pointList.head->data->x;
            for (int i = pointList.head->data->x; i < diff + 1; i++)
            {
                DATA* pointData = [self createAndFindPointData:i];
                [pointList append:pointData];
            }
        }
        
    }
    
    
    struct t_node* c = pointList.tail;
    while (c != nil)
    {
        c->data->top = -1;
        c->data->bottom = 9999;
        
        xCoord = (c->data->x) * ([SAMAudioModel sharedAudioModel].editArea.size.width / stftLength);
        [self findTopAndBottom:xCoord top:&c->data->top bottom:&c->data->bottom];
        
        if (c->data->x == begin)
            pointList.begin = c;
        if (c->data->x == end)
            pointList.end = c;
        
        c = c->nextNode;
    }
    
        // traverse test
//        struct t_node* current = pointList.tail;
//        while (current != nil)
//        {
//            NSLog(@"x: %f \ttop: %f \tbottom: %f", current->data->x, current->data->top, current->data->bottom);
//            current = current->nextNode;
//        }
}

- (DATA *)createAndFindPointData:(int)index
{
    float xCoord;
    DATA* pointData = (DATA *)malloc(sizeof(DATA));
    pointData->x = index + begin;
    pointData->top = -1;
    pointData->bottom = 9999;
    
    xCoord = (pointData->x) * ([SAMAudioModel sharedAudioModel].editArea.size.width / stftLength);
    [self findTopAndBottom:xCoord top:&pointData->top bottom:&pointData->bottom];
    
    return pointData;
}


- (void)findTopAndBottom:(float)xPosition top:(double *)top bottom:(double *)bottom
{
    float intersect = -1;
    for (int i = 0; i < numVertices; i++)
    {
        //intersect = getIntersectionPoint(model->poly, i, xPosition);
        intersect = [self getIntersectionPoint:xPosition with:i];
        if (intersect != -1)
        {
            if (intersect >= *top)
            {
                *top = intersect;
            }
            if (intersect <= *bottom)
            {
                *bottom = intersect;
            }
        }
    }
    
    if (*top == -1)
        *top = 0;
    if (*bottom == 9999)
        *bottom = 0;
    
    [self changeTouchYScale:top];
    [self changeTouchYScale:bottom];
}


- (BOOL)inSegment:(GLKVector2)segment with:(float)point
{
    if (segment.x != segment.y)
    {    // S is not  vertical
        if (segment.x <= point && point <= segment.y)
            return YES;
        if (segment.x >= point && point >= segment.y)
            return YES;
    }
    
    return NO;
}

// TODO: ignoring vertical lines probably not the right thing to do
- (float)getIntersectionPoint:(float)xPosition with:(int)lineNumber
{
    float y2 = polygon.vertices[(lineNumber + 1) % polygon.numVertices].y;
    float y1 = polygon.vertices[lineNumber].y;
    
    float x2 = polygon.vertices[(lineNumber + 1) % polygon.numVertices].x;
    float x1 = polygon.vertices[lineNumber].x;
    
    float m = (y2 - y1) / (x2 - x1);
    float b = y1 - m * x1;
    
    GLKVector2 segment = GLKVector2Make(x1, x2);
    
    if ([self inSegment:segment with:xPosition])
    {
        float y = m * xPosition + b;
        y = polygon.bounds.size.height - y;
        return y;
    }
    
    return -1;
    
}

- (void)changeTouchYScale:(double *)inputPoint
{
    *inputPoint = pow(*inputPoint, 2.0) / [SAMAudioModel sharedAudioModel].touchScale;
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

    GLKVector2 centroid = [self findCentroid];
    
    for (int i = 0; i < numVertices - 1; i++)
    {
        Ellipse* circle = [circles objectAtIndex:i];
        circle.angle = atan2(polygon.vertices[i].y - centroid.y, polygon.vertices[i].x - centroid.x) * 180 / PI;
    }
    
    Ellipse* circle = [[Ellipse alloc] init];
    circle.radiusX = CIRCLE_RADIUS;
    circle.radiusY = CIRCLE_RADIUS;
    circle.position = newPosition;
    circle.color = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
    circle.bounds = bounds;
    circle.angle = atan2(polygon.vertices[numVertices].y - centroid.y, polygon.vertices[numVertices].x - centroid.x) * 180 / PI;

    for (int i = 0; i < numVertices - 1; i++)
    {
        Ellipse* lowCircle = [circles objectAtIndex:i];
        Ellipse* highCircle = [circles objectAtIndex:i+1];
        BOOL insert = NO;
        
        if (circle.angle >= lowCircle.angle && circle.angle <= highCircle.angle)
        {
            [circles insertObject:circle atIndex:i+1];
            insert = YES;
        }
        if (insert)
            break;
    }
    
    [self updateLines];
}

#pragma mark - Render -
- (void)render
{
    [polygon render];
    [lines makeObjectsPerformSelector:@selector(render)];
    [circles makeObjectsPerformSelector:@selector(render)];
}

@end
