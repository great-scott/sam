//
//  SAMSpectrogramViewController.m
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMSpectrogramViewController.h"
#import "SAMAudioModel.h"

#define SPECTRUM_BAR_WIDTH 4

@interface SAMSpectrogramViewController ()

@end

@implementation SAMSpectrogramViewController

// value, a, r, g, b
GLfloat colorLevels[] = {
    0., 1., 0., 0., 0.,
    .333, 1., .7, 0., 0.,
    .667, 1., 0., 0., 1.,
    1., 1., 0., 1., 1.,
};

double linearInterp(double valA, double valB, double fract)
{
	return valA + ((valB - valA) * fract);
}

@synthesize editMode;
@synthesize redAmt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(EAGLContext *) parentContext
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        touchTracker = [[SAMTouchTracker alloc] init];
        touchTracker.view = self.view;
        context = parentContext;
        effect = [[GLKBaseEffect alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    if (!context)
//        NSLog(@"Failed to create ES context.");
//    
    GLKView* view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:context];
    view.context = context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.multipleTouchEnabled = YES;
    //self.preferredFramesPerSecond = 10.0;
    
    stft = [[SAMAudioModel sharedAudioModel] stftBuffer];
    
    redAmt = 0.9;
    editMode = NO;
    
    spectrum = [[NSMutableArray alloc] init];
    
    [self createSpectrum];
}

- (void)createSpectrum
{
    [spectrum removeAllObjects];
    
    int numBins = [[SAMAudioModel sharedAudioModel] windowSize] / 8.0;  // TODO: get this to line up with audio
    int numFrames = (stft->size - 5) / [[SAMAudioModel sharedAudioModel] overlap]; // TODO: this is ridic
    // x
    for (int i = 0; i < numFrames; i++)
    {
        
        for (int step = 0; step < 1; step++)
        {
            Shape* s = [[Shape alloc] init];
            s.bounds = self.view.bounds;
            s.numVertices = numBins;            // number of vertical bins
            s.useConstantColor = NO;
            
            FFT_FRAME* frame = stft->buffer[i];
            
            // y
            for (int j = 0; j < numBins; j++)
            {
                float ypos = s.bounds.size.height - (j * (s.bounds.size.height / numBins));
                float xpos = i * (s.bounds.size.width / numFrames) + (step * 10);
                
                s.vertices[j] = GLKVector2Make(xpos, ypos);
                float amt = (frame->polarWindow->buffer[j].mag) * 200;
                GLKVector4 vertColor;
                
                if (amt > 0.02)
                    vertColor = GLKVector4Make(amt, 0.0, 0.2, 0.9);
                else
                    vertColor = GLKVector4Make(0.95, 0.95, 0.95, 0.4);
                
                s.vertexColors[j] = vertColor;
            }
            
            s.lineWidth = 40.0;
            s.drawingStyle = GL_LINE_STRIP;
            [spectrum addObject:s];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self render];
}

- (void)setupViewForSpectrum
{
	glClearColor(0., 0., 0., 0.);
	spectrumBounds = self.view.bounds;
	
	// The bit buffer for the texture needs to be 512 pixels, because OpenGL textures are powers of
	// two in either dimensions. Our texture is drawing a strip of 300 vertical pixels on the screen,
	// so we need to step up to 512 (the nearest power of 2 greater than 300).
	textureBitBuffer = (UInt32 *)(malloc(sizeof(UInt32) * 512));                    //TODO: change 512 value
	
	// Clears the view with black
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	NSUInteger textureCount = ceil(CGRectGetWidth(spectrumBounds) / (CGFloat)SPECTRUM_BAR_WIDTH);
	GLuint *textureNames;
	
	textureNames = (GLuint *)(malloc(sizeof(GLuint) * textureCount));
	glGenTextures(textureCount, textureNames);
	
	SpectrumLinkedTexture *currentTexture = NULL;
	firstTexture = (SpectrumLinkedTexture *)(calloc(1, sizeof(SpectrumLinkedTexture)));
	firstTexture->textureName = textureNames[0];
	currentTexture = firstTexture;
	
	bzero(textureBitBuffer, sizeof(UInt32) * 512);
	glBindTexture(GL_TEXTURE_2D, currentTexture->textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	for (int i = 1; i < textureCount; i++)
	{
		currentTexture->nextTexture = (SpectrumLinkedTexture *)(calloc(1, sizeof(SpectrumLinkedTexture)));
		currentTexture = currentTexture->nextTexture;
		currentTexture->textureName = textureNames[i];
		
		glBindTexture(GL_TEXTURE_2D, currentTexture->textureName);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	}
	
	// Enable use of the texture
	glEnable(GL_TEXTURE_2D);
	// Set a blending function to use
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	glEnable(GL_BLEND);
	free(textureNames);
}


- (void)renderFFTToTex
{
	UInt32 *texBitBuffer_ptr = textureBitBuffer;
	
	static int numLevels = sizeof(colorLevels) / sizeof(GLfloat) / 5;
	
	int y, maxY;
	maxY = CGRectGetHeight(spectrumBounds);
    
	for (y = 0; y < maxY; y++)
	{
		CGFloat interpVal = 0.5;
		UInt32 newPx = 0xFF000000;
		
		int level_i;
		const GLfloat *thisLevel = colorLevels;
		const GLfloat *nextLevel = colorLevels + 5;
		for (level_i=0; level_i<(numLevels-1); level_i++)
		{
			if ( (*thisLevel <= interpVal) && (*nextLevel >= interpVal) )
			{
				double fract = (interpVal - *thisLevel) / (*nextLevel - *thisLevel);
				newPx =
				((UInt8)(255. * linearInterp(thisLevel[1], nextLevel[1], fract)) << 24)
				|
				((UInt8)(255. * linearInterp(thisLevel[2], nextLevel[2], fract)) << 16)
				|
				((UInt8)(255. * linearInterp(thisLevel[3], nextLevel[3], fract)) << 8)
				|
				(UInt8)(255. * linearInterp(thisLevel[4], nextLevel[4], fract))
				;
				break;
			}
			
			thisLevel+=5;
			nextLevel+=5;
		}
		
		*texBitBuffer_ptr++ = newPx;
	}
	
	glBindTexture(GL_TEXTURE_2D, firstTexture->textureName);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureBitBuffer);

}

- (void)render
{	
    [spectrum makeObjectsPerformSelector:@selector(render)];
}


@end
