//
//  SAMLinkedList.m
//  sam
//
//  Created by Scott McCoid on 3/19/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMLinkedList.h"

@implementation SAMLinkedList
@synthesize head;
@synthesize tail;
@synthesize current;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        head = nil;
        tail = nil;
        index = 0;
        length = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [self clear];
}

- (void)clear
{
    // traverse down and deallocate nodes (data too?)
    struct t_node* c = tail;
    struct t_node* next = nil;
    
    while (c != nil)
    {
        next = c->nextNode;
        free(c->data);
        free(c);
        c = next;
    }
    
    head = nil;
    tail = nil;
    index = 0;
    length = 0;
}

- (void)append:(DATA *)newData
{
    // allocate new node
    struct t_node* newNode = (struct t_node *)malloc(sizeof(struct t_node));
    newNode->index = index;
    newNode->data = newData;
    
    // if this is the first node
    if (length == 0)
    {
        tail = newNode;     // beginning
        current = tail;     // set current to the beginning
    }
    
    if (head != nil)
    {
        head->nextNode = newNode;
    }
    
    newNode->prevNode = head;
    newNode->nextNode = nil;
    head = newNode;
        
    index++;
    length++;
}

@end
