//
//  FFTFrame.h
//  sam
//
//  Created by Scott McCoid on 2/1/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef sam_FFTFrame_h
#define sam_FFTFrame_h

#include "FFT.h"

typedef struct t_fftFrame
{
    FFT*            fft;
    COMPLEX_SPLIT   complexBuffer;
    
    int             windowSize;
    
} FFTFrame;

// Constructor
FFTFrame* newFFTFrame(FFT* fft, int windowSize);

// Destructor
void freeFFTFrame(FFTFrame* frame);

#endif
