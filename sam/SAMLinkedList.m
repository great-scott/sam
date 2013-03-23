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
    if (list.current->nextNode != nil && list.current->data->x != list.end->data->x)
    {
        list.current = list.current->nextNode;
        list.cursor++;
    }
    else
    {
        //list.current = list.tail;
        list.current = list.begin;
        list.cursor = 0;
    }
}

void moveListBackward(SAMLinkedList* list)
{
    if (list.current->prevNode != nil && list.current->data->x != list.begin->data->x)
    {
        list.current = list.current->prevNode;
        list.cursor--;
    }
    else
    {
        //list.current = list.head;
        list.current = list.end;
        list.cursor = list.length - 1;
    }
}


@implementation SAMLinkedList
@synthesize head;
@synthesize tail;
@synthesize current;
@synthesize length;
@synthesize cursor;
@synthesize begin;
@synthesize end;

- (id)init
{
    self = [super init];
    
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
    current = nil;
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
        begin = tail;       // set current to the beginning
    }
    
    if (head != nil)
    {
        head->nextNode = newNode;
    }
    
    if (index == cursor)            // TODO: this is kind of unnecessary 
    {
        current = newNode;
    }
    
    newNode->prevNode = head;
    newNode->nextNode = nil;
    head = newNode;
    end = head;
        
    index++;
    length++;
}

// I think this will mainly be used for inserting at the tail of a list, so this is fine
- (void)insert:(DATA *)newData at:(int)xPosition
{    
    struct t_node* newNode = (struct t_node *)malloc(sizeof(struct t_node));
    newNode->index = xPosition;
    newNode->data = newData;
    
    newNode->prevNode = nil;
    newNode->nextNode = tail;
    tail->prevNode = newNode;
    
    tail = newNode;
}

- (void)update:(DATA *)data top:(float)top bottom:(float)bottom
{
    data->top = top;
    data->bottom = bottom;
}


- (void)forward
{
    if (current->nextNode != nil && current->nextNode != end)
    {
        current = current->nextNode;
    }
    else
    {
        current = begin;
    }
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
