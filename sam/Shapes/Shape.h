//
//  TREShape.h
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface TREShape : NSObject
{
    NSMutableData *vertexData;
    NSMutableData *vertexColorData;
    
    GLKVector4 color;
    GLKVector2 position;
    GLKVector2 scale;
    float depth;
    int number;
}

@property (readonly) int numVertices;
@property (readonly) GLKVector2 *vertices;
@property (readonly) GLKVector4 *vertexColors;
@property (readonly) GLKMatrix4 projectionMatrix;

@property GLKVector4 color;
@property GLKVector2 position;
@property GLKVector2 scale;
@property float depth;
@property float left, right, bottom, top;
@property GLfloat lineWidth;
@property GLubyte drawingStyle;
@property int number;

- (void)update;
- (void)render;
+ (GLKBaseEffect *)getEffect;

@end
