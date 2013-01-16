//
//  Shape.m
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "Shape.h"
#define M_TAU (2 * M_PI)

static BOOL initialized = NO;
static GLKBaseEffect *effect;

@implementation Shape

@synthesize scale;
@synthesize color;
@synthesize depth;
@synthesize left, right, top, bottom;
@synthesize lineWidth;
@synthesize drawingStyle;
@synthesize number;
@synthesize bounds;
@synthesize grabPoint;

@synthesize position;

+ (void)initialize
{
    if (!initialized)
    {
        effect = [[GLKBaseEffect alloc] init];
        initialized = YES;
    }
}

+ (GLKBaseEffect *)getEffect
{
    if (initialized)
    {
        return effect;
    }
    else 
    {
        effect = [[GLKBaseEffect alloc] init];
        initialized = YES;
        return effect;
    }
}

-(id)init 
{
    self = [super init];
    if (self) 
    {
        color = GLKVector4Make(1,1,1,1);
        position = GLKVector2Make(0,0);
        scale = GLKVector2Make(1.0, 1.0);
        depth = 0.0;
        
        lineWidth = 1.0;
        drawingStyle = GL_TRIANGLE_FAN;
    }
    return self;
}

- (int)numVertices
{
    return numVertices;
}

- (void)setNumVertices:(int)vertices
{
    numVertices = vertices;
    if (vertexData == nil)
        vertexData = [NSMutableData dataWithLength:sizeof(GLKVector2) * self.numVertices];
    else
        [vertexData setLength:sizeof(GLKVector2) * self.numVertices];
        
}

- (GLKVector2 *)vertices
{
    if (vertexData == nil)
        vertexData = [NSMutableData dataWithLength:sizeof(GLKVector2) * self.numVertices];

    return [vertexData mutableBytes];
}

- (GLKVector4 *)vertexColors {
    if (vertexColorData == nil)
        vertexColorData = [NSMutableData dataWithLength:sizeof(GLKVector4) * self.numVertices];
    return [vertexColorData mutableBytes];
}

//- (void)setPosition:(GLKVector2)newPosition
//{
//    GLKVector2 differenceOfPositions = GLKVector2Subtract(newPosition, grabPoint);
//
//    for (int i = 0; i < self.numVertices; i++)
//        self.vertices[i] = GLKVector2Add(self.vertices[i], differenceOfPositions);
//    
//    position = GLKVector2Add(differenceOfPositions, position);
//    grabPoint = GLKVector2Add(differenceOfPositions, grabPoint);
//}
//
//- (GLKVector2)getPosition
//{
//    return position;
//}

- (void)update
{
    // nothing here yet
}

- (void)render
{
    effect.useConstantColor = YES;
    effect.constantColor = self.color;
    
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(scale.x, scale.y, depth);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, depth);
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix, scaleMatrix);
    
    effect.transform.modelviewMatrix = modelMatrix;
    effect.transform.projectionMatrix = self.projectionMatrix;
    
    [effect prepareToDraw];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glLineWidth(lineWidth);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.vertices);
    glDrawArrays(drawingStyle, 0, self.numVertices);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisable(GL_BLEND);
}

//-(GLKMatrix4)projectionMatrix {
//    return GLKMatrix4MakeOrtho(left, right, bottom, top, 1, -1);
//}

-(GLKMatrix4)projectionMatrix
{
    return GLKMatrix4MakeOrtho(bounds.origin.x, bounds.size.width, bounds.size.height, bounds.origin.y, 1, -1);
}


@end
