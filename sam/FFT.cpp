//
//  FFT.cpp
//  sam
//
//  Created by Scott McCoid on 1/28/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include "FFT.h"

FFT::FFT(int fftWindowSize, int windowType = vDSP_HANN_NORM)
{
    windowSize = fftWindowSize;
    halfWindowSize = windowSize / 2;
    normFactor = 1.0 / (2 * windowSize);
    log2n = log2f(windowSize);
    
    // create setup
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    
    // create window
    window = new float[windowSize];
    vDSP_hann_window(window, windowSize, windowType);
    
    // create intermediate forward/inverse buffers
    forwardBuffer = new float[windowSize];
    inverseBuffer = new float[windowSize];
}

FFT::~FFT()
{
    delete[] window;
    delete[] forwardBuffer;
    delete[] inverseBuffer;
    
    vDSP_destroy_fftsetup(fftSetup);
}

void FFT::forwardFFT(FFTFrame* frame, float* buffer)
{
    // window
    vDSP_vmul(buffer, 1, window, 1, forwardBuffer, 1, windowSize);
    
    // data packing
    //vDSP_ctoz((COMPLEX*)forwardBuffer, 2)
}


void FFT::inverseFFT(FFTFrame* frame, float* buffer)
{
    
}