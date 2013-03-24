//
//  SAMRecord.m
//  sam
//
//  Created by Scott McCoid on 3/24/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMRecord.h"

@implementation SAMRecord

- (id)init
{
    self = [super init];
    
    if (self)
    {
        recordedSequence = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)snapshot:(SAMAudioModel *)model
{
    for (int i = 0; i < MAX_VOICES; i++)
    {
//        if (model->voiceReferences[i] != nil)
//        {
//            //RegionPolygon* poly = NSCopyObject(model->shapeReferences[i], 0, nil);
//            //[recordedSequence addObject:poly];
//        }
    }
    
}

@end
