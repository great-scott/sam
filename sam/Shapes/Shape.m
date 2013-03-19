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
@synthesize useConstantColor;

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
        texture = nil;
        useConstantColor = YES;
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

    return (GLKVector2 *)[vertexData mutableBytes];
}

- (GLKVector4 *)vertexColors {
    if (vertexColorData == nil)
        vertexColorData = [NSMutableData dataWithLength:sizeof(GLKVector4) * self.numVertices];
    return (GLKVector4 *)[vertexColorData mutableBytes];
}

- (GLKVector2 *)textureCoordinates {
    if (textureCoordinateData == nil)
        textureCoordinateData = [NSMutableData dataWithLength:sizeof(GLKVector2)*self.numVertices];
    return (GLKVector2 *)[textureCoordinateData mutableBytes];
}

- (void)render
{

    effect.useConstantColor = useConstantColor;
    effect.constantColor = self.color;
    
    if (texture != nil) {
        effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        effect.texture2d0.target = GLKTextureTarget2D;
        effect.texture2d0.name = texture.name;
    }
    
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(scale.x, scale.y, depth);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, depth);
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translateMatrix, scaleMatrix);
    
    effect.transform.modelviewMatrix = modelMatrix;
    effect.transform.projectionMatrix = self.projectionMatrix;
    
    [effect prepareToDraw];
    
    //---------------------------------------------------------
    
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
//    glBlendEquation(GL_FUNC_ADD);
//    glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE);
    
    glLineWidth(lineWidth);
    
    if (texture != nil)
    {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.textureCoordinates);
    }
    if (!useConstantColor) {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, self.vertexColors);
    }
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.vertices);
    
    glDrawArrays(drawingStyle, 0, self.numVertices);
    
    if (texture != nil)
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    if (!useConstantColor)
        glDisableVertexAttribArray(GLKVertexAttribColor);
    
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
