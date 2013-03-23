//
//  SAMToolbarViewController.h
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SAMToolbarViewControllerDelegate <NSObject>

@required
- (IBAction)toolbarButtonPressed:(UIButton *)sender;

@optional
- (IBAction)handlePress:(UILongPressGestureRecognizer *)recognizer;

@end


@interface SAMToolbarViewController : UIViewController

@property (nonatomic, weak) id <SAMToolbarViewControllerDelegate> delegate;

@end
