//
//  PhaseVocoder.cpp
//  sam
//
//  Created by Scott McCoid on 1/30/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include <cassert>
#include "PhaseVocoder.h"

#define PI 3.14159265359
#define TWO_PI (2 * PI)

PhaseVocoder::PhaseVocoder(FFT* fftManager)
{
    fft = fftManager;
    
    polarWindow = new POLAR[fft->getHalfWindowSize()];
    polarWindowMod = new POLAR[fft->getHalfWindowSize()];
    
    complexFrame = new FFTFrame(fft->getWindowSize());
}

PhaseVocoder::~PhaseVocoder()
{
    delete[] polarWindow;
    delete[] polarWindowMod;
    
    delete complexFrame;
}

void PhaseVocoder::analyze(float* buffer, PhaseVocoder& previousPV, int hopSize)
{
    float mag, phi, delta;
    COMPLEX_SPLIT* complex;
    
    float scale = (float)(TWO_PI * hopSize / fft->getWindowSize());
    float fac = (float)(44100.0 / (hopSize * TWO_PI));
    
    fft->forwardFFT(complexFrame, buffer);
    
    complex = complexFrame->getComplex();
    
    for (int i = 1; i < fft->getHalfWindowSize(); i++)
    {
        mag = getMagnitude(complex->realp[i], complex->imagp[i]);
        phi = getPhase(complex->realp[i], complex->imagp[i]);
        
        delta = phi - previousPV[i].phase;
        
        while (delta > PI) delta -= (float)TWO_PI;
        while (delta < PI) delta += (float)TWO_PI;
        
        polarWindow[i].phase = (delta + i * scale) * fac;
        polarWindow[i].mag = mag;
    }
}

void PhaseVocoder::synthesize(float* buffer)
{
    COMPLEX_SPLIT* complex = complexFrame->getComplex();
    
    for (int i = 1; i < fft->getHalfWindowSize(); i++)
    {
        complex->realp[i] = polarWindow[i].mag * cos(polarWindow[i].phase);
        complex->imagp[i] = polarWindow[i].mag * sin(polarWindow[i].phase);
    }
    
    fft->inverseFFT(complexFrame, buffer);
}

float PhaseVocoder::getMagnitude(float real, float imag)
{
    return sqrt(real * real + imag * imag);
}

double PhaseVocoder::getPhase(float real, float imag)
{
    return atan2((double)imag, (double)real);
}

POLAR& PhaseVocoder::operator[] (const int nIndex)
{
    assert(nIndex >= 0 && nIndex < fft->getHalfWindowSize());
    
    return polarWindow[nIndex];
}

void PhaseVocoder::fixPhase(PhaseVocoder& previousPV, float factor)
{
    int length = fft->getHalfWindowSize();
    for (int i = 0; i < length; i++)
    {
        float previousPhase = previousPV[i].phase;
        polarWindow[i].phase = factor * (polarWindow[i].phase - previousPhase) + previousPhase;
    }
}




