//
//  SAMSpectrogramViewController.m
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMSpectrogramViewController.h"

@interface SAMSpectrogramViewController ()

@property (strong, nonatomic) EAGLContext* context;

@end

@implementation SAMSpectrogramViewController
@synthesize context = _context;
@synthesize editMode;
@synthesize redAmt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        touchTracker = [[SAMTouchTracker alloc] init];
        touchTracker.view = self.view;
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
    
    redAmt = 0.9;
    editMode = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(redAmt, 0.6, 0.6, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)pressHandle:(UILongPressGestureRecognizer *)sender
{
    //CGPoint point = sender.view.
}


@end
