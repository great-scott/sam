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
    
    squares = [[NSMutableArray alloc] init];
    triangles = [[NSMutableArray alloc] init];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationLandscapeLeft;
}


#pragma mark - View Drawing Callback -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.95, 0.95, 0.95, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if ([squares count] > 0)
        [squares makeObjectsPerformSelector:@selector(render)];
    
    if ([triangles count] > 0)
        [triangles makeObjectsPerformSelector:@selector(render)];
}


#pragma mark - View Methods -

- (void)addSquare
{
    RegionPolygon* poly = [[RegionPolygon alloc] initWithRect:self.view.bounds];
    poly.numVertices = 4;
    [squares addObject:poly];
}

- (void)addTriangle
{
    RegionPolygon* triangle = [[RegionPolygon alloc] initWithRect:self.view.bounds];
    triangle.numVertices = 3;
    [triangles addObject:triangle];
}

#pragma mark - Touch Callbacks -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker startTouches:touches withEvent:event withShapes:squares];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker moveTouches:touches withEvent:event withShapes:squares];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchTracker endTouches:touches withEvent:event withShapes:squares];
}


@end
