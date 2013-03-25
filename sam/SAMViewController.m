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
@synthesize spectroViewControl;
@synthesize gestureViewControl;

@synthesize fileView;
@synthesize optionsView;
@synthesize toolbarView;
@synthesize editView;
@synthesize spectroView;
@synthesize gestureView;

@synthesize calculatingView;

@synthesize optionsViewOpen;
@synthesize segmentControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupView];
    [self setupFileView];
    [self setupOptionsView];
    [self setupFileDirectory];
    
    audioStatus = NO;
    optionsViewOpen = NO;
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
    
    [calculatingView setHidden:YES];
    
}

- (void)setupOptionsView
{
    NSArray* subviewArray = [[NSBundle mainBundle] loadNibNamed:@"OptionsView" owner:self options:nil];
    optionsView = [subviewArray objectAtIndex:0];
    
    float fileViewX = editView.bounds.size.width - optionsView.bounds.size.width - 5.0;
    float fileViewY = editView.bounds.size.height - optionsView.bounds.size.height - 5.0;
    
    CGRect rect = CGRectMake(fileViewX, fileViewY, optionsView.bounds.size.width, optionsView.bounds.size.height);
    [optionsView setFrame:rect];
    [optionsView setAlpha:0];
    [optionsView setHidden:YES];
    
    rect = CGRectMake(20, 153, 310, 44);
    NSArray* segments = [[NSArray alloc] initWithObjects:@"1.0", @"0.5", @"0.25", @"0.125", nil];
    segmentControl = [[UISegmentedControl alloc] initWithItems:segments];
    [segmentControl setFrame:rect];
    [segmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentControl setTintColor:[UIColor whiteColor]];
    
    NSDictionary* styleDictNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor lightGrayColor], UITextAttributeTextColor,
                                     [UIFont fontWithName:@"Courier" size:17.0], UITextAttributeFont,
                                     nil];
    
    NSDictionary* styleDictSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor blackColor], UITextAttributeTextColor,
                                     [UIFont fontWithName:@"Courier" size:17.0], UITextAttributeFont,
                                     nil];
    
    [segmentControl setTitleTextAttributes:styleDictNormal forState:UIControlStateNormal];
    [segmentControl setTitleTextAttributes:styleDictSelect forState:UIControlStateSelected];
    
    // add action
    [segmentControl addTarget:editViewControl action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentControl setSelectedSegmentIndex:-1];
    
    // add it as a subview
    [optionsView addSubview:segmentControl];
    
    rect = CGRectMake(18, 292, 314, 23);
    UISlider* gainSlider = [[UISlider alloc] initWithFrame:rect];
    [gainSlider setBackgroundColor:[UIColor clearColor]];
    [gainSlider setMinimumTrackTintColor:[UIColor clearColor]];
    [gainSlider setMaximumTrackTintColor:[UIColor whiteColor]];
    
    [gainSlider addTarget:self action:@selector(gainChanged:) forControlEvents:UIControlEventValueChanged];
    
    [optionsView addSubview:gainSlider];
    
    
    [self.view addSubview:optionsView];
    
}


- (void)gainChanged:(id)sender
{
    
    
}


- (void)animateFileView:(BOOL)inTrueOutFalse
{
    switch ([[NSNumber numberWithBool:inTrueOutFalse] integerValue])
    {
        case TRUE: //Fade In
        {
            [fileView setHidden:NO];
            [UIView animateWithDuration: 0.6
                             animations:^{[fileView setAlpha:1.0];}
                             completion:^(BOOL finished){;}];
            break;
        }
        case FALSE: //Fade Out
        {
            [UIView animateWithDuration: 0.6
                             animations:^{[fileView setAlpha:0.0];}
                             completion:^(BOOL finished){[fileView setHidden:YES];}];
            break;
        }
    }
}


- (void)animateOptionsView:(BOOL)inTrueOutFalse
{
    switch ([[NSNumber numberWithBool:inTrueOutFalse] integerValue])
    {
        case TRUE: //Fade In
        {
            [optionsView setHidden:NO];
            [UIView animateWithDuration: 0.4
                             animations:^{[optionsView setAlpha:1.0];}
                             completion:^(BOOL finished){;}];
            break;
        }
        case FALSE: //Fade Out
        {
            [UIView animateWithDuration: 0.4
                             animations:^{[optionsView setAlpha:0.0];}
                             completion:^(BOOL finished){[optionsView setHidden:YES];}];
            [segmentControl setSelectedSegmentIndex:-1];                                    // resets the rate button each time you close (could be an issue)
            break;
        }
    }
}

- (IBAction)openPressed:(UIButton *)sender
{
    if (fileSelected)
    {
        BOOL finished;
        [[SAMAudioModel sharedAudioModel] openAudioFile:fileUrl];
        finished = [[SAMAudioModel sharedAudioModel] calculateSTFT];
        
        [self animateFileView:NO];
        [editViewControl addSpectrogramView];
    }
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
        [self animateFileView:YES];
    }
    else if ([title isEqualToString:@"Save"])
    {
        NSLog(@"Save Pressed.");
    }
    else if ([title isEqualToString:@"Square"])
    {
        // Add Square
        [editViewControl addSquare:GLKVector2Make(100, 100)];
    }
    else if ([title isEqualToString:@"Play"])
    {

    }
    else if ([title isEqualToString:@"Record"])
    {
        if ([[SAMAudioModel sharedAudioModel] isRecording] == NO)
        {
            [[SAMAudioModel sharedAudioModel] startRecording];
            [[SAMAudioModel sharedAudioModel] setIsRecording:YES];
            sender.backgroundColor = [UIColor redColor];
        }
        else
        {
            [[SAMAudioModel sharedAudioModel] setIsRecording:NO];
            [[SAMAudioModel sharedAudioModel] stopRecording];
            sender.backgroundColor = [UIColor lightGrayColor];
        }
    }
    else if ([title isEqualToString:@"Tri"])
    {
        [editViewControl addTriangle:GLKVector2Make(100, 100)];
    }
    else if ([title isEqualToString:@"Options"])
    {
        if (optionsViewOpen == NO)
        {
            [self animateOptionsView:YES];
            optionsViewOpen = YES;
        }
        else
        {
            [self animateOptionsView:NO];
            optionsViewOpen = NO;
        }
    }
    else if ([title isEqualToString:@"DAC"])
    {
        // Turn On/Off Audio Unit / Session
        if (audioStatus == NO)
        {
            [[SAMAudioModel sharedAudioModel] startAudioPlayback];
            sender.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.8 blue:0.2 alpha:1.0];
            audioStatus = YES;
        }
        else
        {
            [[SAMAudioModel sharedAudioModel] stopAudioPlayback];
            sender.backgroundColor = [UIColor lightGrayColor];
            audioStatus = NO;
        }
    }
}


#pragma mark - TableView Delegate Methods - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *selectedFile = [tableData objectAtIndex:indexPath.row];
    
    if ([selectedFile.pathExtension compare:@"wav" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:selectedFile];
        fileUrl = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)fullPath, kCFURLPOSIXPathStyle, false);
        fileSelected = YES;
    }
    else
    {
        fileSelected = NO;
    }
}

- (void)setupFileDirectory
{
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil)
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
    
    if ([files count] > 0)
    {
        tableData = [[NSArray alloc] initWithArray:files];
        NSString* firstFile = [files objectAtIndex:0];
    
        if ([firstFile.pathExtension compare:@"wav" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {   
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:firstFile];
            fileUrl = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)fullPath, kCFURLPOSIXPathStyle, false);
            fileSelected = YES;
        }
    }
}


#pragma mark - TableView Data Source methods - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger num = [tableData count];
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    return cell;
}

@end
