//
//  SAMRecord.h
//  sam
//
//  Created by Scott McCoid on 3/24/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMAudioModel.h"
#import "RegionPolygon.h"

@interface SAMRecord : NSObject
{
    NSMutableArray* recordedSequence;
}

- (void)snapshot:(SAMAudioModel *)model;     // an array of polygon references

@end
