//
//  Voice.c
//  sam
//
//  Created by Scott McCoid on 3/21/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include <stdlib.h>
#include "Voice.h"

VOICE* newVoice(short number, int windowSize)
{
    VOICE* voice = (VOICE*)malloc(sizeof(VOICE));
    voice->number = number;
    
    voice->transform = (float*)malloc(windowSize * sizeof(float));
    voice->output= (float*)malloc(windowSize * sizeof(float));
    
    return voice;
}

void freeVoice(VOICE* voice)
{
    free(voice->transform);
    free(voice->output);
    free(voice);
}