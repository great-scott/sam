//
//  FFT.c
//  sam
//
//  Created by Scott McCoid on 2/1/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include "FFT.h"

// Constructor
FFT* newFFT(int windowSize, int windowType)
{
    // New fft struct
    FFT* fft = (FFT *)malloc(sizeof(FFT));
    
    // Assign parameters
    fft->windowSize = windowSize;
    fft->halfWindowSize = windowSize / 2;
    fft->normFactor = 1.0 / (2 * windowSize);
    fft->log2n = log2f(windowSize);
    
    // create setup
    fft->fftSetup = vDSP_create_fftsetup(fft->log2n, FFT_RADIX2);
    
    // create window
    fft->window = (float *)malloc(fft->windowSize * sizeof(float));
    vDSP_hann_window(fft->window, fft->windowSize, windowType);
    
    // create intermediate forward/inverse buffers
    fft->forwardBuffer = (float *)malloc(fft->windowSize * sizeof(float));
    fft->inverseBuffer = (float *)malloc(fft->windowSize * sizeof(float));
    
    fft->internalComplex.realp = (float *)malloc(fft->halfWindowSize * sizeof(float));
    fft->internalComplex.imagp = (float *)malloc(fft->halfWindowSize * sizeof(float));
    
}

// Destructor
void freeFFT(FFT* fft)
{
    free(fft->internalComplex.realp);
    free(fft->internalComplex.imagp);
    free(fft->inverseBuffer);
    free(fft->forwardBuffer);
    free(fft->window);
    
    vDSP_destroy_fftsetup(fft->fftSetup);
    
    free(fft);
}

// Forward fft
void forwardFFT(FFTFrame* frame, float* buffer)
{
    FFT* fft = frame->fft;
    COMPLEX_SPLIT* complex = frame->complexBuffer;
    
    // window
    vDSP_vmul(buffer, 1, fft->window, 1, fft->forwardBuffer, 1, fft->windowSize);
    
    // data packing
    vDSP_ctoz((COMPLEX*)fft->forwardBuffer, 2, complex, 1, fft->halfWindowSize);
    
    // take fft
    vDSP_fft_zip(fft->fftSetup, complex, 1, fft->log2n, FFT_FORWARD);
    
    // scale
    vDSP_vsmul(complex->realp, 1, &fft->normFactor, complex->realp, 1, fft->halfWindowSize);
    vDSP_vsmul(complex->imagp, 1, &fft->normFactor, complex->imagp, 1, fft->halfWindowSize);
    
    // Zero out DC offset
    complex->realp[0] = 0.0;
    complex->imagp[0] = 0.0;
    
}

void inverseFFT(FFTFrame* frame, float* buffer)
{
    FFT* fft = frame->fft;
    COMPLEX_SPLIT* complex = frame->complexBuffer;
    // Pv stuff?
    
    // Inverse fft
    vDSP_fft_zrop(fft->fftSetup, complex, 1, &fft->internalComplex, 1, fft->log2n, FFT_INVERSE);
    
    // data packing
    vDSP_ztoc(&fft->internalComplex, 1, (COMPLEX *)fft->inverseBuffer, 2, fft->halfWindowSize);
    
    // windowing
    vDSP_vsmul(fft->inverseBuffer, 1, fft->window, buffer, 1, fft->windowSize);
    
}


