//
//  SAMGestureRecognizers.h
//  sam
//
//  Created by Scott McCoid on 3/24/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SAMTapGestureRecognizer : UITapGestureRecognizer


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)reset;

@property (nonatomic, strong) UITouch* firstTouch;

@end

@protocol SAMTapGestureRecognizerDelegate <UIGestureRecognizerDelegate>

- (void)removeTap:(UITouch *)touch;

@end