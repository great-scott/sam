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
    complexBuffer.realp = new float[halfWindowSize];
    complexBuffer.imagp = new float[halfWindowSize];
    
    // Polar window
//    polarBuffer.buffer = new POLAR[halfWindowSize];
//    polarBuffer.length = halfWindowSize;
}


FFTFrame::~FFTFrame()
{
    delete[] complexBuffer.realp;
    delete[] complexBuffer.imagp;
}


COMPLEX_SPLIT* FFTFrame::getComplex()
{
    return &complexBuffer;
}


//POLAR_WINDOW* FFTFrame::getPolar()
//{
//    return &polarBuffer;
//}