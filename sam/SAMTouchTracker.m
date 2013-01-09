//
//  SAMTouchTracker.m
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMTouchTracker.h"


@implementation SAMTouchTracker
@synthesize touchContainer;

- (id)init
{
    self = [super init];
    
    if (self)
    {   
        touchContainer = [[SAMTouchContainer alloc] init];
    }
    
    return self;
}


#pragma mark - Touch Tracker Methods -

- (void)startTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    
}

- (void)moveTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    
}

- (void)endTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes
{
    
}



@end
