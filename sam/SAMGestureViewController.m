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
@synthesize editMode;
@synthesize spectroViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        touchTracker = [[SAMTouchTracker alloc] init];
        touchTracker.view = self.view;
        //spectroViewController = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.opaque = NO; // NB: Apple DELETES THIS VALUE FROM NIB
    self.view.backgroundColor = [UIColor clearColor];
    
    editMode = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressHandle:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        editMode = !editMode;
        if (editMode == YES && spectroViewController != nil)
            spectroViewController.redAmt = 0.5;
        else if (editMode == NO && spectroViewController != nil)
            spectroViewController.redAmt = 0.9;
    }
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender
{
    if (editMode == YES)
    {
        sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
        sender.scale = 1;
        
        spectroViewController.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
        //sender.scale = 1;
    }
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender
{
    if (editMode == YES)
    {
        CGPoint translation = [sender translationInView:self.view];
        sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                             sender.view.center.y + translation.y);
        
        spectroViewController.view.center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        [sender setTranslation:CGPointMake(0, 0) inView:spectroViewController.view];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    [touchTracker startTouches:touches withEvent:event withShapes:shapes];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    [touchTracker moveTouches:touches withEvent:event withShapes:shapes];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    [touchTracker endTouches:touches withEvent:event withShapes:shapes];
}
@end
