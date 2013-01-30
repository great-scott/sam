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
    
    internalComplex.realp = new float[halfWindowSize];
    internalComplex.imagp = new float[halfWindowSize];
    
}

FFT::~FFT()
{
    delete[] window;
    delete[] forwardBuffer;
    delete[] inverseBuffer;
    
    delete[] internalComplex.realp;
    delete[] internalComplex.imagp;
    
    vDSP_destroy_fftsetup(fftSetup);
}

void FFT::forwardFFT(FFTFrame* frame, float* buffer)
{
    COMPLEX_SPLIT* complex = frame->getComplex();
    
    // window
    vDSP_vmul(buffer, 1, window, 1, forwardBuffer, 1, windowSize);
    
    // data packing
    vDSP_ctoz((COMPLEX*)forwardBuffer, 2, complex, 1, halfWindowSize);
    
    // take fft
    vDSP_fft_zip(fftSetup, complex, 1, log2n, FFT_FORWARD);
    
    // scale
    vDSP_vsmul(complex->realp, 1, &normFactor, complex->realp, 1, halfWindowSize);
    vDSP_vsmul(complex->imagp, 1, &normFactor, complex->imagp, 1, halfWindowSize);
    
    // Zero out DC offset
    complex->realp[0] = 0.0;
    complex->imagp[0] = 0.0;
    
    // Calculate PV stuff
    
}


void FFT::inverseFFT(FFTFrame* frame, float* buffer)
{
    COMPLEX_SPLIT* complex = frame->getComplex();
    // Pv stuff?
    
    // Inverse fft
    vDSP_fft_zrop(fftSetup, complex, 1, &internalComplex, 1, log2n, FFT_INVERSE);
    
    // data packing
    vDSP_ztoc(&internalComplex, 1, (COMPLEX *)inverseBuffer, 2, halfWindowSize);
    
    // windowing
    vDSP_vsmul(inverseBuffer, 1, window, buffer, 1, windowSize);
    
}


int FFT::getWindowSize()
{
    return windowSize;
}

int FFT::getHalfWindowSize()
{
    return halfWindowSize;
}






