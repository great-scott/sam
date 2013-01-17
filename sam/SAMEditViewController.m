//
//  SAMEditViewController.m
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMEditViewController.h"

@interface SAMEditViewController ()

@property (strong, nonatomic) EAGLContext* context;

@end

@implementation SAMEditViewController
@synthesize context = _context;
@synthesize spectroViewControl;
@synthesize spectroView;

#pragma mark - View Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        touchTracker = [[SAMTouchTracker alloc] init];
        touchTracker.view = self.view;                      // set the touch tracker's view to this view for easy reference
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context)
        NSLog(@"Failed to create ES context.");
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.multipleTouchEnabled = YES;
    self.view.opaque = NO; // NB: Apple DELETES THIS VALUE FROM NIB
    self.view.backgroundColor = [UIColor clearColor];
    
    shapes = [[NSMutableArray alloc] init];
    [[SAMAudioModel sharedAudioModel] setShapeReference:shapes];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationLandscapeLeft;
}


#pragma mark - View Drawing Callback -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    glClearColor(0.95, 0.95, 0.95, 0.0);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if ([shapes count] > 0)
        [shapes makeObjectsPerformSelector:@selector(render)];
}


#pragma mark - View Methods -

- (void)addSquare
{
    RegionPolygon* poly = [[RegionPolygon alloc] initWithRect:self.view.bounds];
    poly.numVertices = 4;
    [shapes addObject:poly];
}

- (void)addTriangle
{
    // The default is 3 vertices for a region polygon, so we don't need to specify the number of them
    RegionPolygon* triangle = [[RegionPolygon alloc] initWithRect:self.view.bounds];
    [shapes addObject:triangle];
}

- (void)addSpectrogram
{
    spectroViewControl = [[SAMSpectrogramViewController alloc] initWithNibName:@"SpectrogramView" bundle:[NSBundle mainBundle]];
    spectroView = spectroViewControl.view;
    CGRect spectroRect = CGRectMake(0, 0, spectroView.bounds.size.width, spectroView.bounds.size.height);
    [spectroView setHidden:YES];
    [spectroView setFrame:spectroRect];
    [self.view addSubview:spectroView];
}

#pragma mark - Touch Callbacks -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker startTouches:touches withEvent:event withShapes:shapes];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker moveTouches:touches withEvent:event withShapes:shapes];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker endTouches:touches withEvent:event withShapes:shapes];
}


@end
