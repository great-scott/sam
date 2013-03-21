//
//  Voice.h
//  sam
//
//  Created by Scott McCoid on 3/21/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef sam_Voice_h
#define sam_Voice_h

typedef struct t_voice
{
    short  number;              // the number of the voice / index
    float* transform;           // the buffer we do any transformations into (e.g. ifft)
    float* output;              // output buffer for overlap adding
    
} VOICE;

// Constructor
VOICE* newVoice(short number, int windowSize);

// Destructor
void freeVoice(VOICE* voice);

#endif
