//
//  SAMViewController.m
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMViewController.h"

#define TOOLBAR_X_LOC 958

@interface SAMViewController ()

@end

@implementation SAMViewController
@synthesize editViewControl;
@synthesize toolbarViewControl;
@synthesize fileView;
@synthesize toolbarView;
@synthesize editView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupView];
    [self setupFileView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationLandscapeLeft;
}

#pragma mark - Main View Initialization - 

- (void)setupView
{
    editViewControl = [[SAMEditViewController alloc] initWithNibName:@"EditView" bundle:[NSBundle mainBundle]];
    toolbarViewControl = [[SAMToolbarViewController alloc] initWithNibName:@"ToolbarView" bundle:[NSBundle mainBundle]];
    toolbarViewControl.delegate = self;
    
    // Settings for Edit View
    editView = editViewControl.view;
    CGRect editRect = CGRectMake(0, 0, editView.bounds.size.width, editView.bounds.size.height);
    [editView setHidden:NO];
    [editView setFrame:editRect];
    
    [self.view addSubview:editView];
    
    // Settings for Toolbar View
    toolbarView = toolbarViewControl.view;
    CGRect toolRect = CGRectMake(TOOLBAR_X_LOC, 0, toolbarView.bounds.size.width, toolbarView.bounds.size.height);
    [toolbarView setHidden:NO];
    [toolbarView setFrame:toolRect];
    
    [self.view addSubview:toolbarView];
}

#pragma mark - File View Methods - 

- (void)setupFileView
{
    NSArray* subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FileView" owner:self options:nil];
    fileView = [subviewArray objectAtIndex:0];
    
    float fileViewX = editView.center.x - fileView.bounds.size.width / 2;
    float fileViewY = editView.center.y - fileView.bounds.size.height / 2;
    
    CGRect rect = CGRectMake(fileViewX, fileViewY, fileView.bounds.size.width, fileView.bounds.size.height);
    [fileView setFrame:rect];
    [fileView setAlpha:0];
    [fileView setHidden:YES];
    
    [self.view addSubview:fileView];
}


- (void)animateFileView:(BOOL)inTrueOutFalse
{
    switch ([[NSNumber numberWithBool:inTrueOutFalse] integerValue]) {
        case TRUE: //Fade In
        {
            [fileView setHidden:NO];
            [UIView animateWithDuration: 1.0
                             animations:^{[fileView setAlpha:1.0];}
                             completion:^(BOOL finished){;}];
            break;
        }
        case FALSE: //Fade Out
        {
            [UIView animateWithDuration: 1.0
                             animations:^{[fileView setAlpha:0.0];}
                             completion:^(BOOL finished){[fileView setHidden:YES];}];
            break;
        }
    }
}

- (IBAction)openPressed:(UIButton *)sender
{
    [self animateFileView:NO];
}

- (IBAction)cancelPressed:(UIButton *)sender
{
    [self animateFileView:NO];
}

# pragma mark - Toolbar Button Callback - 

- (IBAction)toolbarButtonPressed:(UIButton *)sender
{
    NSString* title = sender.currentTitle;
    
    if ([title isEqualToString:@"File"])
    {
        NSLog(@"File Pressed.");
        [self animateFileView:YES];
    }
    else if ([title isEqualToString:@"Save"])
        NSLog(@"Save Pressed.");
    
}

@end
