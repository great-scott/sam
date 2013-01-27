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
@synthesize toolbarView;
@synthesize editView;
@synthesize spectroView;
@synthesize gestureView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupView];
    [self setupFileView];
    [self setupFileDirectory];
    
    audioStatus = NO;
    //audioModel = [[SAMAudioModel alloc] init];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationLandscapeLeft;
}


#pragma mark - Main View Initialization - 

- (void)setupView
{
    //[self addSpectrogramView];
    
    editViewControl = [[SAMEditViewController alloc] initWithNibName:@"EditView" bundle:[NSBundle mainBundle]];
    toolbarViewControl = [[SAMToolbarViewController alloc] initWithNibName:@"ToolbarView" bundle:[NSBundle mainBundle]];
    toolbarViewControl.delegate = self;
    
    //editViewControl.context = spectroViewControl.context;
    [editViewControl reinit];
    
    // Settings for Edit View
    editView = editViewControl.view;
    CGRect editRect = CGRectMake(0, 0, editView.bounds.size.width, editView.bounds.size.height);
    [editView setHidden:NO];
    [editView setFrame:editRect];
    [self.view addSubview:editView];
    //[editViewControl setSpectroViewControl:spectroViewControl];
    //[self addGestureView];          // sandwiching views
    
    // Settings for Toolbar View
    toolbarView = toolbarViewControl.view;
    CGRect toolRect = CGRectMake(TOOLBAR_X_LOC, 0, toolbarView.bounds.size.width, toolbarView.bounds.size.height);
    [toolbarView setHidden:NO];
    [toolbarView setFrame:toolRect];
    [self.view addSubview:toolbarView];
}

- (void)addSpectrogramView
{
    spectroViewControl = [[SAMSpectrogramViewController alloc] initWithNibName:@"SpectrogramView" bundle:[NSBundle mainBundle]];
    spectroView = spectroViewControl.view;
    CGRect spectroRect = CGRectMake(500, 0, spectroView.bounds.size.width, spectroView.bounds.size.height);
    [spectroView setHidden:NO];
    [spectroView setFrame:spectroRect];
    [self.view addSubview:spectroView];
}

- (void)addGestureView
{
    gestureViewControl = [[SAMGestureViewController alloc] initWithNibName:@"GestureView" bundle:[NSBundle mainBundle]];
    gestureView = gestureViewControl.view;
    CGRect gestureRect = CGRectMake(0, 0, gestureView.bounds.size.width, gestureView.bounds.size.height);
    [gestureView setHidden:NO];
    [gestureView setFrame:gestureRect];
    [self.view addSubview:gestureView];
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
}


- (void)animateFileView:(BOOL)inTrueOutFalse
{
    switch ([[NSNumber numberWithBool:inTrueOutFalse] integerValue])
    {
        case TRUE: //Fade In
        {
            [fileView setHidden:NO];
            [UIView animateWithDuration: 1.0
                             animations:^{[fileView setAlpha:1.0];}
                             completion:^(BOOL finished){;}];
            break;
        }
        case FALSE: //Fade Out
        {
            [UIView animateWithDuration: 1.0
                             animations:^{[fileView setAlpha:0.0];}
                             completion:^(BOOL finished){[fileView setHidden:YES];}];
            break;
        }
    }
}

- (IBAction)openPressed:(UIButton *)sender
{
    if (fileSelected)
    {
        [[SAMAudioModel sharedAudioModel] openAudioFile:fileUrl];
        [[SAMAudioModel sharedAudioModel] calculateSTFT];
        //[spectroView setHidden:NO];
        [self animateFileView:NO];
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
        // Edit View Add Square
        [editViewControl addSquare];
    }
    else if ([title isEqualToString:@"Play"])
    {
        if ([[SAMAudioModel sharedAudioModel] monitor] == NO)
            [[SAMAudioModel sharedAudioModel] setMonitor:YES];
        else
            [[SAMAudioModel sharedAudioModel] setMonitor:NO];
    }
    else if ([title isEqualToString:@"Tri"])
    {
        [editViewControl addTriangle];
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
