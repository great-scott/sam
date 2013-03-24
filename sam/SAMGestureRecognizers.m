//
//  SAMGestureRecognizers.m
//  sam
//
//  Created by Scott McCoid on 3/24/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMGestureRecognizers.h"

@implementation SAMTapGestureRecognizer
@synthesize firstTouch;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if ([touches count] == 1 && self.state == UIGestureRecognizerStatePossible)
    {
        if (firstTouch == nil)
            firstTouch = [touches anyObject];
    }
}

- (void)reset
{
    [super reset];
    if (self.state == UIGestureRecognizerStateFailed)
        firstTouch = nil;
    
    if ([self.delegate respondsToSelector:@selector(removeTap:)])
    {
        if (self.state == UIGestureRecognizerStateRecognized)
        {
            [(id)self.delegate removeTap:firstTouch];
        }
    }
}

@end
