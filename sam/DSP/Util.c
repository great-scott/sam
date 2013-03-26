//
//  Util.c
//  sam
//
//  Created by Scott McCoid on 3/26/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include <stdio.h>
#include "Util.h"

void reverse(float* input, int left, int right)
{
    float* p1 = input + left;
    float* p2 = input + right;
    
    while (p1 < p2)
    {
        char temp = *p1;
        *p1 = *p2;
        *p2 = temp;
        p1++;
        p2--;
    }
}


void swap(float* input, int indexA, int indexB)
{
    input[indexA] += input[indexB];
    input[indexB] = input[indexA] - input[indexB];
    input[indexA] = input[indexA] - input[indexB];
}


void rotate(float* input, int amount, int length)
{
    amount = amount % length;
    
    for (int i = 0; i < amount; i++)
    {
        int j = (i + amount) % length;
        swap(input, i, j);
        j = (i - 1 + length) % length;
        swap(input, i, j);
    }
}



