//
//  FFT.h
//  sam
//
//  Created by Scott McCoid on 2/1/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef sam_FFT_h
#define sam_FFT_h

#include <Accelerate/Accelerate.h>
#include "Constants.h"
#include "FFTFrame.h"

typedef struct t_fft
{
    int             windowSize;
    int             halfWindowSize;
    float           normFactor;
    
    float*          window;
    float*          forwardBuffer;
    float*          inverseBuffer;
    
    COMPLEX_SPLIT   internalComplex;
    vDSP_Length     log2n;
    FFTSetup        fftSetup;
    
} FFT;

// Constructor
FFT* newFFT(int windowSize, int windowType);

// Destructor
void freeFFT(FFT* fft);

// Forward fft
void forwardFFT(FFTFrame* frame, float* buffer);

void inverseFFT(FFTFrame* frame, float* buffer);

#endif
