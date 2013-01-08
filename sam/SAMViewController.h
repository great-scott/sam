//
//  SAMViewController.h
//  sam
//
//  Created by Scott McCoid on 1/7/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAMEditViewController.h"
#import "SAMToolbarViewController.h"

@interface SAMViewController : UIViewController <SAMToolbarViewControllerDelegate>

@property (nonatomic,strong) SAMEditViewController *editViewControl;
@property (nonatomic,strong) SAMToolbarViewController *toolbarViewControl;

@end
