//
//  Rectangle.m
//  TRE
//
//  Created by Scott McCoid on 10/17/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "Rectangle.h"
#define WIDTH 100.0
#define HEIGHT 100.0

@implementation Rectangle

- (int)numVertices
{
    return 4;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.drawingStyle = GL_TRIANGLE_FAN;
    }
    
    return self;
}

- (void)setVertexPosition:(int)index forPosition:(GLKVector2)_newPosition
{
    if (index < self.numVertices)
    {
        self.vertices[index] = _newPosition;
    }
}

@end
