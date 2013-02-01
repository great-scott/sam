//
//  FFTFrame.c
//  sam
//
//  Created by Scott McCoid on 2/1/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include <stdio.h>
#include "FFTFrame.h"

// Constructor
FFTFrame* newFFTFrame(FFT* fft, int windowSize)
{
    FFTFrame* frame = (FFTFrame *)malloc(sizeof(FFTFrame));
    
    frame->fft = fft;
    frame->windowSize = windowSize;
    
    // Complex buffer
    frame->complexBuffer.realp = (float *)malloc(frame->fft->halfWindowSize * sizeof(float));
    frame->complexBuffer.imagp = (float *)malloc(frame->fft->halfWindowSize * sizeof(float));
}

// Destructor
void freeFFTFrame(FFTFrame* frame)
{
    free(frame->complexBuffer.realp);
    free(frame->complexBuffer.imagp);
    
    free(frame);
}