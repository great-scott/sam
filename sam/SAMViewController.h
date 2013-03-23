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
#import "SAMAudioModel.h"
#import "SAMSpectrogramViewController.h"
#import "SAMGestureViewController.h"

@interface SAMViewController : UIViewController <SAMToolbarViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *tableData;
    NSString *documentsDirectory;
    
    CFURLRef fileUrl;
    BOOL fileSelected;
    BOOL audioStatus;   // whether the audio is on or off (YES = on, NO = off);
    
    SAMAudioModel* audioModel;
}

@property (nonatomic, strong) SAMEditViewController* editViewControl;
@property (nonatomic, strong) SAMToolbarViewController* toolbarViewControl;
@property (nonatomic, strong) SAMSpectrogramViewController* spectroViewControl;
@property (nonatomic, strong) SAMGestureViewController* gestureViewControl;

@property (nonatomic, strong) UIView* fileView;
@property (nonatomic, strong) UIView* optionsView;
@property (nonatomic, strong) UIView* editView;
@property (nonatomic, strong) UIView* toolbarView;
@property (nonatomic, strong) UIView* spectroView;
@property (nonatomic, strong) UIView* gestureView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *calculatingView;

@property BOOL optionsViewOpen;

// File Browser Callbacks
- (IBAction)openPressed:(UIButton *)sender;
- (IBAction)cancelPressed:(UIButton *)sender;

@end
