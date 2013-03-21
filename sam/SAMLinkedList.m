//
//  SAMLinkedList.m
//  sam
//
//  Created by Scott McCoid on 3/19/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#import "SAMLinkedList.h"

void moveListForward(SAMLinkedList* list)
{
    if (list.current->nextNode != nil)
    {
        list.current = list.current->nextNode;
        list.cursor++;
    }
    else
    {
        list.current = list.tail;
        list.cursor = 0;
    }
}

void moveListBackward(SAMLinkedList* list)
{
    if (list.current->prevNode != nil)
    {
        list.current = list.current->prevNode;
        list.cursor--;
    }
    else
    {
        list.current = list.head;
        list.cursor = list.length - 1;
    }
}


@implementation SAMLinkedList
@synthesize head;
@synthesize tail;
@synthesize current;
@synthesize length;
@synthesize cursor;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        head = nil;
        tail = nil;
        index = 0;
        length = 0;
        cursor = 0;
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
        //current = tail;     // set current to the beginning
    }
    
    if (head != nil)
    {
        head->nextNode = newNode;
    }
    
    if (index == cursor)
    {
        current = newNode;
    }
    
    newNode->prevNode = head;
    newNode->nextNode = nil;
    head = newNode;
        
    index++;
    length++;
}

- (void)forward
{
    if (current->nextNode != nil)
        current = current->nextNode;
    else
        current = tail;
}

- (void)backward
{
    if (current->prevNode != nil)
        current = current->prevNode;
    else
        current = head;
}

- (void)cursorCheck
{
    if (cursor >= length || cursor <= 0)
    {
        cursor = 0;
        current = tail;
    }
}

@end
