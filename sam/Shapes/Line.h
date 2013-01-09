//
//  Line.h
//  TRE
//
//  Created by Scott McCoid on 10/16/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "Shape.h"

@interface Line : Shape
{
    GLKVector2 startPoint, endPoint;
}

@property GLKVector2 startPoint;
@property GLKVector2 endPoint;

@end
