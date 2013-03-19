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

- (IBAction)handlePress:(UILongPressGestureRecognizer *)recognizer
{
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        UIWindow* wholeWindow = [UIApplication sharedApplication].keyWindow;
        
        float _x = wholeWindow.bounds.size.height - [recognizer locationInView:self.view].x - 50;        // used heigh here because of portrait mode
        float _y = [recognizer locationInView:self.view].y - 100;
        
        NSNumber *x = [NSNumber numberWithFloat:_x];
        NSNumber *y = [NSNumber numberWithFloat:_y];
        
        // I know this is a button
        UIButton* button = (UIButton*)recognizer.view;
        NSString* title = button.currentTitle;
        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:title,@"title",x,@"x",y,@"y",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewSquare"
                                                            object:self
                                                          userInfo:dict];
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        UIWindow* wholeWindow = [UIApplication sharedApplication].keyWindow;
        
        float _x = wholeWindow.bounds.size.height + [recognizer locationInView:self.view].x - 150;        // used heigh here because of portrait mode
        float _y = [recognizer locationInView:self.view].y - 100;
        
        NSNumber *x = [NSNumber numberWithFloat:_x];
        NSNumber *y = [NSNumber numberWithFloat:_y];
        
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:x,@"x",y,@"y",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveSquare"
                                                            object:self
                                                          userInfo:dict];

    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dropSquare" object:self];
    }
    

}
@end
