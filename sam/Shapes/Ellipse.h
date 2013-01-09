//
//  TREEllipse.h
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "TREShape.h"
#import "TREEllipseView.h"
#import <GLKit/GLKit.h>

@interface TREEllipse : TREShape
{
    float radiusX, radiusY;
    BOOL stillInside;
}

@property float radiusX;
@property float radiusY;
@property BOOL stillInside;

- (BOOL)isInside:(GLKVector2)_coordinates;

@end