//
//  SAMSpectrogramViewController.m
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMSpectrogramViewController.h"
#import "SAMAudioModel.h"

#define SPECTRUM_BAR_WIDTH 20
#define MAX_LINES 120
#define LINE_OFFSET 5.0
#define LINE_SPACING 8.0

@interface SAMSpectrogramViewController ()

@end

@implementation SAMSpectrogramViewController


@synthesize editMode;
@synthesize redAmt;
@synthesize gain;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(EAGLContext *) parentContext
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        touchTracker = [[SAMTouchTracker alloc] init];
        touchTracker.view = self.view;
        context = parentContext;
        //effect = [[GLKBaseEffect alloc] init];
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
//    GLKView* view = (GLKView *)self.view;
//    [EAGLContext setCurrentContext:context];
//    view.context = context;
//    view.drawableMultisample = GLKViewDrawableMultisample4X;
//    view.multipleTouchEnabled = YES;

    
    stft = [[SAMAudioModel sharedAudioModel] stftBuffer];
    
    redAmt = 0.9;
    editMode = NO;
    
    spectrum = [[NSMutableArray alloc] init];
    gain = 400;
    
//    [self createSpectrum];
}

- (void)createSpectrum
{
    [spectrum removeAllObjects];
    
    int numBins = [[SAMAudioModel sharedAudioModel] windowSize] / 16.0;  // TODO: get this to line up with audio
    int numFrames = stft->size;
    
    NSLog(@"Number of Frames: %i", stft->size);
    NSLog(@"Width: %f\tHeight: %f", self.view.bounds.size.width, self.view.bounds.size.height);
    // x
    
    int numLines;
    
    if (numFrames < MAX_LINES)
        numLines = numFrames;
    else
        numLines = MAX_LINES;
    
    for (int timeIndex = 0; timeIndex < numLines; timeIndex++)
    {
        Shape* s = [[Shape alloc] init];
        s.bounds = self.view.bounds;
        s.numVertices = numBins;
        s.useConstantColor = NO;
        
        int xpos = timeIndex * LINE_SPACING + LINE_OFFSET;
        double ypos;
        
        FFT_FRAME* frame = stft->buffer[timeIndex];
        
        // y
        for (int j = 0; j < numBins; j++)
        {
            ypos = s.bounds.size.height - (j * (s.bounds.size.height / numBins));
            //ypos = j;
            [RegionPolygon changeTouchYScale:&ypos];
            
            s.vertices[j] = GLKVector2Make(xpos, ypos);
            float amt = pow(((frame->polarWindow->buffer[j].mag) * gain), 0.35);
            GLKVector4 vertColor;
            
            if (amt > 0.02)
                vertColor = GLKVector4Make(1.0 - amt, 1.0 - amt, 1.0 - amt, 0.9);
            else
                vertColor = GLKVector4Make(0.95, 0.95, 0.95, 0.95);
            
            s.vertexColors[j] = vertColor;
        }

        
        s.lineWidth = 20.0;
        s.drawingStyle = GL_LINE_STRIP;
        [spectrum addObject:s];
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

- (void)render
{	
    [spectrum makeObjectsPerformSelector:@selector(render)];
}


@end
