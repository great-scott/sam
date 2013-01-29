//
//  FFT.h
//  sam
//
//  Created by Scott McCoid on 1/28/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef __sam__FFT__
#define __sam__FFT__

#include <iostream>
#include <Accelerate/Accelerate.h>
#include "FFTFrame.h"

class FFT
{
    public:
        // Constructor
        FFT(int fftWindowSize, int windowType);
    
        // Destructor
        ~FFT();
    
        // Forward fft
        void forwardFFT(FFTFrame* frame, float* buffer);
    
        // Inverse fft
        void inverseFFT(FFTFrame* frame, float* buffer);
    
    private:
    
        int             windowSize;
        int             halfWindowSize;
        float           normFactor;
    
        float*          window;
        float*          forwardBuffer;
        float*          inverseBuffer;
    
        COMPLEX_SPLIT   internalComplex;
        vDSP_Length     log2n;
        FFTSetup        fftSetup;

};



#endif /* defined(__sam__FFT__) */
