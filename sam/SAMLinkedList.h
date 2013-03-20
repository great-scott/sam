//
//  SAMLinkedList.h
//  sam
//
//  Created by Scott McCoid on 3/19/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//
//  This is a project specific implementation of a linked list.
//  Instead of being general, the data is specific to this project.
//
//

#import <Foundation/Foundation.h>


// Data can be allocated externally, but it is cleaned up internally
typedef struct t_data
{
    float           x;
    double          top;
    double          bottom;
} DATA;

struct t_node
{
    int             index;          // key for searching
    DATA*           data;
    struct t_node*  nextNode;
    struct t_node*  prevNode;
};

@interface SAMLinkedList : NSObject
{
    struct t_node* head;
    struct t_node* tail;
    
    int   index;
    int   length;
}


@property struct t_node* head;
@property struct t_node* tail;

- (void)append:(DATA *)newNode;
- (void)clear;

@end
