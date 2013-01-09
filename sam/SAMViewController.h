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

@interface SAMViewController : UIViewController <SAMToolbarViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *tableData;
    NSString *documentsDirectory;
    
    CFURLRef fileUrl;
    BOOL fileSelected;
}

@property (nonatomic, strong) SAMEditViewController* editViewControl;
@property (nonatomic, strong) SAMToolbarViewController* toolbarViewControl;

@property (nonatomic, strong) UIView* fileView;
@property (nonatomic, strong) UIView* editView;
@property (nonatomic, strong) UIView* toolbarView;

// File Browser Callbacks
- (IBAction)openPressed:(UIButton *)sender;
- (IBAction)cancelPressed:(UIButton *)sender;

@end
