//
//  TRELine.m
//  TRE
//
//  Created by Scott McCoid on 10/16/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "Line.h"

@implementation TRELine


-(id)init 
{
    self = [super init];
    if (self) 
    {        
        self.lineWidth = 1.0;
        self.drawingStyle = GL_LINE_STRIP;
    }
    return self;
}


- (int)numVertices
{
    return 2;
}

- (void)setStartPoint:(GLKVector2)_startPoint
{
    self.vertices[0] = _startPoint;
    startPoint = _startPoint;
}

- (GLKVector2)startPoint
{
    return startPoint;
}

- (void)setEndPoint:(GLKVector2)_endPoint
{
    self.vertices[1] = _endPoint;
    endPoint = _endPoint;
}

- (GLKVector2)endPoint
{
    return endPoint;
}


@end
