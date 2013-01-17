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
        // Custom initialization
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
    glClearColor(redAmt, 0.9, 0.9, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

//- (IBAction)handlePress:(UILongPressGestureRecognizer *)sender
//{
//    if (sender.state == UIGestureRecognizerStateEnded)
//    {
//        editMode = !editMode;
//        if (editMode == YES)
//            redAmt = 0.5;
//        else
//            redAmt = 0.9;
//    }
//}
//
//- (IBAction)handlePan:(UIPanGestureRecognizer *)sender {
//}
//
//- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender {
//}

@end
