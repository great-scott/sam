//
//  SAMTouchTracker.h
//  sam
//
//  Created by Scott McCoid on 1/8/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//
//  This class is tied heavily to the regionSquare / polygon stuff

#import <Foundation/Foundation.h>
#import "SAMTouchContainer.h"

@interface SAMTouchTracker : NSObject

@property (nonatomic, strong) SAMTouchContainer* touchContainer;

- (void)startTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
- (void)moveTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;
- (void)endTouches:(NSSet *)touches withEvent:(UIEvent *)event withShapes:(NSMutableArray *)shapes;

@end
