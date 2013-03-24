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
    int             x;
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
    struct t_node* current;
    
    struct t_node* begin;
    struct t_node* end;
    
    int   index;
    int   length;
    int   cursor;
}

@property struct t_node* head;
@property struct t_node* tail;
@property struct t_node* current;       // this is different from other situations, this pointer acts as the 'playhead' in a way
@property int length;
@property int cursor;                   // somewhat silly, but tries to keep position state after clear
@property BOOL  movingForward;          // YES = forward, NO = reverse

@property struct t_node* begin;
@property struct t_node* end;

- (void)append:(DATA *)newNode;
- (void)insert:(DATA *)newData at:(int)xPosition;
- (void)update:(DATA *)node top:(float)top bottom:(float)bottom;
- (void)clear;
- (void)forward;                     // TODO: consider having utility methods for moving/wrapping current pointer
- (void)backward;
- (void)cursorCheck;

@end

void moveListForward(SAMLinkedList* list);
void moveListBackward(SAMLinkedList* list);
void moveListForwardReverse(SAMLinkedList* list);

