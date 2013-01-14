//
//  RegionPolygon.h
//  sam
//
//  Created by Scott McCoid on 1/14/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "Shape.h"


@interface RegionPolygon : Shape
{
    int numVertices;
    
    NSMutableArray* vertices;
    NSMutableArray* lines;
    NSMutableArray* circles;
    
    GLKVector2 grabpoint;
    GLKVector2 position;
}

@property int numVertices;
@property GLKVector4 color;         // Different parts have a different color relationship and will change on their own

@end
