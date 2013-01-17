//
//  SAMGestureViewController.m
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMGestureViewController.h"

@interface SAMGestureViewController ()

@end

@implementation SAMGestureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        touchTracker = [[SAMTouchTracker alloc] init];
        touchTracker.view = self.view;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.opaque = NO; // NB: Apple DELETES THIS VALUE FROM NIB
    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressHandle:(UILongPressGestureRecognizer *)sender
{
    
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [touchTracker startTouches:touches withEvent:event withShapes:shapes];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [touchTracker moveTouches:touches withEvent:event withShapes:shapes];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [touchTracker endTouches:touches withEvent:event withShapes:shapes];
//}
@end
