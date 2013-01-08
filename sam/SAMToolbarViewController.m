//
//  SAMToolbarViewController.m
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMToolbarViewController.h"

@interface SAMToolbarViewController ()

@end

@implementation SAMToolbarViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toolbarButtonPressed:(UIButton *)sender
{
    if (delegate && [delegate respondsToSelector:@selector(toolbarButtonPressed:)])
    {
        [delegate toolbarButtonPressed:sender];
    }
}
@end
