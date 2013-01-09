//
//  Ellipse.m
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "Ellipse.h"

#define EE_ELLIPSE_RESOLUTION 64
#define M_TAU (2*M_PI)

@implementation Ellipse
@synthesize stillInside;

-(int)numVertices 
{
    return EE_ELLIPSE_RESOLUTION;
}

-(void)updateVertices 
{
    for (int i = 0; i < EE_ELLIPSE_RESOLUTION; i++)
    {
        float theta = ((float)i) / EE_ELLIPSE_RESOLUTION * M_TAU;
        self.vertices[i] = GLKVector2Make(cos(theta) * radiusX, sin(theta) * radiusY);
    }
}

-(float)radiusX 
{
    return radiusX;
}

-(void)setRadiusX:(float)_radiusX 
{
    radiusX = _radiusX;
    [self updateVertices];
}

-(float)radiusY 
{
    return radiusY;
}

-(void)setRadiusY:(float)_radiusY 
{
    radiusY = _radiusY;
    [self updateVertices];
}


// This assumes a circle where radius X and radius Y are the same length
- (BOOL)isInside:(GLKVector2)_coordinates
{
    
    GLKVector2 difference = GLKVector2Subtract(self.position, _coordinates);
    float distance = sqrt(GLKVector2DotProduct(difference, difference));
    
    if (distance < self.radiusX + 25.0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

@end
