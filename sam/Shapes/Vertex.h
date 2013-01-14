//
//  Vertex.h
//  sam
//
//  Created by Scott McCoid on 1/14/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Vertex : NSObject
{
    GLKVector2 position;
    GLKVector4 color;
}

@property GLKVector2 position;
@property GLKVector4 color;

@end
