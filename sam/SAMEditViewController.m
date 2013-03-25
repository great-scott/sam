//
//  SAMEditViewController.m
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMEditViewController.h"

@interface SAMEditViewController ()

//@property (strong, nonatomic) EAGLContext* context;

@end

@implementation SAMEditViewController
@synthesize context;// = _context;
@synthesize spectroViewControl;
@synthesize spectroView;
@synthesize tapRecognizer;

#pragma mark - View Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //touchTracker = [[SAMTouchTracker alloc] init];
        self.view.userInteractionEnabled = YES;
        
        tapRecognizer = [[SAMTapGestureRecognizer alloc]
                         initWithTarget:self
                        action:@selector(handleTap:)];
        
        [tapRecognizer setNumberOfTapsRequired:2];
        tapRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapRecognizer];
        
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
    [EAGLContext setCurrentContext:self.context];
    view.context = self.context;
    
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.multipleTouchEnabled = YES;
    self.view.opaque = NO; // NB: Apple DELETES THIS VALUE FROM NIB
    self.view.backgroundColor = [UIColor clearColor];
    
    shapes = [[NSMutableArray alloc] init];
    [[SAMAudioModel sharedAudioModel] setEditArea:self.view.bounds];
    
    spectroViewControl = nil;
    newMovingShape = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewSquare:)
                                                 name:@"addNewSquare" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveSquare:)
                                                 name:@"moveSquare" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dropSquare:)
                                                 name:@"dropSquare" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setStftSize:)
                                                 name:@"setStftSize" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationLandscapeLeft;
}

- (void)addSpectrogramView
{
    if (spectroViewControl == nil)
    {
        spectroViewControl = [[SAMSpectrogramViewController alloc] initWithNibName:@"SpectrogramView" bundle:[NSBundle mainBundle] context:self.context];
    }
    
    [spectroViewControl createSpectrum];
}


#pragma mark - Notification Center Methods -

- (void)addNewSquare:(NSNotification *)notification
{
    NSNumber* x = [[notification userInfo] valueForKey:@"x"];
    NSNumber* y = [[notification userInfo] valueForKey:@"y"];
    NSString* title = [[notification userInfo] valueForKey:@"title"];
    
    if ([title isEqualToString:@"Square"])
        newMovingShape = [self addSquare:GLKVector2Make([x floatValue], [y floatValue])];
    else if ([title isEqualToString:@"Tri"])
        newMovingShape = [self addTriangle:GLKVector2Make([x floatValue], [y floatValue])];
}

- (void)moveSquare:(NSNotification *)notification
{
    NSNumber *x = [[notification userInfo] valueForKey:@"x"];
    NSNumber *y = [[notification userInfo] valueForKey:@"y"];
    
    [newMovingShape setPosition:GLKVector2Make([x floatValue], [y floatValue]) withSubShape:newMovingShape];
}

- (void)dropSquare:(NSNotification *)notification
{
    newMovingShape = nil;
}

- (void)setStftSize:(NSNotification *)notification
{
    NSNumber* size = [[notification userInfo] valueForKey:@"size"];
    
    for (RegionPolygon* poly in shapes)
    {
        [poly setStftLength:[size intValue]];
    }
}

#pragma mark - View Drawing Callback -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    [spectroViewControl glkView:view drawInRect:rect];
    
    if ([shapes count] > 0)
        [shapes makeObjectsPerformSelector:@selector(render)];
}


#pragma mark - View Methods -

- (RegionPolygon *)addSquare:(GLKVector2)location
{
    if ([SAMAudioModel sharedAudioModel].numberOfVoices < MAX_VOICES)
    {
        RegionPolygon* poly = [[RegionPolygon alloc] initWithRect:self.view.bounds];
        poly.numVertices = 4;
        [poly setPosition:location withSubShape:poly];
        [shapes addObject:poly];
    
        [[SAMAudioModel sharedAudioModel] addShape:poly];
        poly.stftLength = [SAMAudioModel sharedAudioModel].stftBufferSize;
    
        return poly;
    }
    
    return nil;
}

- (RegionPolygon *)addTriangle:(GLKVector2)location
{
    // The default is 3 vertices for a region polygon, so we don't need to specify the number of them
    if ([SAMAudioModel sharedAudioModel].numberOfVoices < MAX_VOICES)
    {
        RegionPolygon* poly = [[RegionPolygon alloc] initWithRect:self.view.bounds];
        poly.numVertices = 3;
        [poly setPosition:location withSubShape:poly];
        [shapes addObject:poly];
        
        [[SAMAudioModel sharedAudioModel] addShape:poly];
        poly.stftLength = [SAMAudioModel sharedAudioModel].stftBufferSize;
    
        return poly;
    }
    
    return nil;
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


#pragma mark - Gesture Callbacks -

- (void)removeTap:(UITouch *)touch
{
    [touchTracker removeTap:touch];
    tapRecognizer.firstTouch = nil;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    [touchTracker handleTap:sender withShapes:shapes];
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    [touchTracker handleSwipe:sender withShapes:shapes];
}

- (IBAction)handleForwardSwipe:(UISwipeGestureRecognizer *)sender
{
    [touchTracker handleForwardSwipe:sender withShapes:shapes];
}

- (IBAction)handleBackwardSwipe:(UISwipeGestureRecognizer *)sender
{
    [touchTracker handleBackwardSwipe:sender withShapes:shapes];
}

- (IBAction)handleUpwardSwipe:(UISwipeGestureRecognizer *)sender
{
    [touchTracker handleUpwardSwipe:sender withShapes:shapes];
}

- (IBAction)handleDownwardSwipe:(UISwipeGestureRecognizer *)sender
{
    [touchTracker handleDownwardSwipe:sender withShapes:shapes];
}


@end
