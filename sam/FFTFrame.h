//
//  FFTFrame.h
//  sam
//
//  Created by Scott McCoid on 1/29/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef __sam__FFTFrame__
#define __sam__FFTFrame__

#include <iostream>
#include "FFT.h"

//typedef struct t_polar
//{
//    float mag;
//    float phase;
//} POLAR;
//
//typedef struct t_polarWindow
//{
//    POLAR* buffer;
//    int    length;
//} POLAR_WINDOW;


class FFTFrame
{
    public:
    
        // Constructor
        FFTFrame(int fftWindowSize);
    
        // Destructor
        ~FFTFrame();
    
        // Returns pointer to complex buffer
        COMPLEX_SPLIT*  getComplex();
//        POLAR_WINDOW*   getPolar();
    
    private:
    
        // Main complex plane buffer
        COMPLEX_SPLIT   complexBuffer;
    
        // Polar coordinates
//        POLAR_WINDOW    polarBuffer;
//        POLAR_WINDOW    polarBufferMod;
    
        int             windowSize;
        int             halfWindowSize;
    
    
};


#endif /* defined(__sam__FFTFrame__) */
