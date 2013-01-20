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
@synthesize gestureViewControl;
@synthesize spectroView;
@synthesize gestureView;

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
    
    spectroViewControl = nil;
    //[self addGestureView];
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

- (IBAction)handlePress:(UILongPressGestureRecognizer *)sender
{
    [spectroViewControl pressHandle:sender];
}

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

- (void)addGestureView
{
    gestureViewControl = [[SAMGestureViewController alloc] initWithNibName:@"GestureView" bundle:[NSBundle mainBundle]];
    gestureView = gestureViewControl.view;
    CGRect gestureRect = CGRectMake(0, 0, gestureView.bounds.size.width, gestureView.bounds.size.height);
    [gestureView setHidden:NO];
    [gestureView setFrame:gestureRect];
    [self.view addSubview:gestureView];
}

- (void)setSpectroViewControl:(SAMSpectrogramViewController *)svc
{
    // TODO: This could get really hairy really quick keep this marked for debugging
    if (svc != nil)
        gestureViewControl.spectroViewController = svc;
    
    spectroViewControl = svc;
}

- (SAMSpectrogramViewController *)spectroViewControl
{
    return spectroViewControl;
}

#pragma mark - Touch Callbacks -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker startTouches:touches withEvent:event withShapes:shapes];
    //[gestureViewControl touchesBegan:touches withEvent:event withShapes:shapes];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker moveTouches:touches withEvent:event withShapes:shapes];
    //[gestureViewControl touchesMoved:touches withEvent:event withShapes:shapes];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker endTouches:touches withEvent:event withShapes:shapes];
    //[gestureViewControl touchesEnded:touches withEvent:event withShapes:shapes];
}


@end
