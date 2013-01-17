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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
