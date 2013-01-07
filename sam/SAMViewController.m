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

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView
{
    editViewControl = [[SAMEditViewController alloc] initWithNibName:@"EditView" bundle:[NSBundle mainBundle]];
    toolbarViewControl = [[SAMToolbarViewController alloc] initWithNibName:@"ToolbarView" bundle:[NSBundle mainBundle]];
    
    // Settings for Edit View
    UIView* editView = editViewControl.view;
    CGRect editRect = CGRectMake(0, 0, editView.bounds.size.width, editView.bounds.size.height);
    [editView setHidden:NO];
    [editView setFrame:editRect];
    
    [self.view addSubview:editView];
    
    // Settings for Toolbar View
    UIView* toolbarView = toolbarViewControl.view;
    CGRect toolRect = CGRectMake(TOOLBAR_X_LOC, 0, toolbarView.bounds.size.width, toolbarView.bounds.size.height);
    [toolbarView setHidden:NO];
    [toolbarView setFrame:toolRect];
    
    [self.view addSubview:toolbarView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationLandscapeLeft;
}


@end
