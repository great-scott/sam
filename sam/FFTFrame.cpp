//
//  FFTFrame.cpp
//  sam
//
//  Created by Scott McCoid on 1/29/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include "FFTFrame.h"


FFTFrame::FFTFrame(int fftWindowSize)
{
    windowSize = fftWindowSize;
    halfWindowSize = windowSize / 2;
    
    // Complex buffer
    complex.realp = new float[halfWindowSize];
    complex.imagp = new float[halfWindowSize];
    
    // Polar window
    polarBuffer.buffer = new POLAR[halfWindowSize];
    polarBuffer.length = halfWindowSize;
}


FFTFrame::~FFTFrame()
{
    delete[] complex.realp;
    delete[] complex.imagp;
}


COMPLEX_SPLIT* FFTFrame::getComplex()
{
    return &complex;
}


POLAR_WINDOW* FFTFrame::getPolar()
{
    return &polarBuffer;
}