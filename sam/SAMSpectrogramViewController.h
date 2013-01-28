//
//  SAMSpectrogramViewController.h
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SAMTouchTracker.h"
#import "FFTManager.h"

typedef struct SpectrumLinkedTexture {
	GLuint							textureName;
	struct SpectrumLinkedTexture	*nextTexture;
} SpectrumLinkedTexture;

double linearInterp(double valA, double valB, double fract);

@interface SAMSpectrogramViewController : GLKViewController
{
    SAMTouchTracker*        touchTracker;
    CGRect                  spectrumBounds;
    UInt32*                 textureBitBuffer;
    SpectrumLinkedTexture*	firstTexture;
    GLKBaseEffect*          effect;
    
    NSMutableArray*         spectrum;
    EAGLContext*            context;
    STFT_BUFFER*            stft;
    
}

@property BOOL editMode;
@property float redAmt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(EAGLContext *) parentContext;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
- (void)createSpectrum;

@end
