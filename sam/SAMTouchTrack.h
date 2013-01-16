//
//  SAMTouchTrack.h
//  sam
//
//  Created by Scott McCoid on 1/16/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMTouchTrack : NSObject
{
    UITouch* touch;
    id       parent;
    id       child;
}

@property (nonatomic, strong) UITouch* touch;
@property (nonatomic, strong) id parent;
@property (nonatomic, strong) id child;

@end
