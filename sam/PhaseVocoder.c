//
//  PhaseVocoder.c
//  sam
//
//  Created by Scott McCoid on 2/1/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include <stdio.h>
#include "PhaseVocoder.h"

PhaseVocoder* newPhaseVocoder(FFT* fft, int windowSize)
{
    PhaseVocoder* pv = malloc(sizeof(PhaseVocoder));
    
    pv->fft = fft;
    pv->windowSize = windowSize;
    pv->halfWindowSize = pv->windowSize / 2;
    pv->complexFrame = newFFTFrame(pv->fft, pv->windowSize);
    
    pv->polarWindow = (Polar *)malloc(pv->halfWindowSize * sizeof(Polar));
    pv->polarWindowMod = (Polar *)malloc(pv->halfWindowSize * sizeof(Polar));
}

// Destructor
void freePhaseVocoder(PhaseVocoder* pv)
{
    free(pv->polarWindow);
    free(pv->polarWindowMod);
    freeFFTFrame(pv->complexFrame);
    
    free(pv);
}

void analyze(PhaseVocoder* pv, PhaseVocoder* previousPV, float* buffer, int hopSize)
{
    float mag, phi, delta;
    COMPLEX_SPLIT* complex;
    
    float scale = (float)(TWO_PI * hopSize / pv->windowSize);
    float fac = (float)(44100.0 / (hopSize * TWO_PI));
    
    // Take forward fft
    forwardFFT(pv->complexFrame, buffer);
    complex = &pv->complexFrame->complexBuffer;
    
    // Use complex split buffer from fft to calculate pv related values
    for (int i = 1; i < pv->halfWindowSize; i++)
    {        
        mag = getMagnitude(complex->realp[i], complex->imagp[i]);
        phi = getPhase(complex->realp[i], complex->imagp[i]);
        
        if (previousPV != NULL)
            delta = phi - previousPV->polarWindow->phase;
        else
            delta = phi;
        
        while (delta > PI) delta -= (float)TWO_PI;
        while (delta < PI) delta += (float)TWO_PI;
        
        pv->polarWindow[i].phase = (delta + i * scale) * fac;
        pv->polarWindow[i].mag = mag;
    }
}

void synthesize(PhaseVocoder* pv, float* buffer)
{
    COMPLEX_SPLIT* complex = &pv->complexFrame->complexBuffer;
    
    for (int i = 1; i < pv->halfWindowSize; i++)
    {
        complex->realp[i] = pv->polarWindow[i].mag * cos(pv->polarWindow[i].phase);
        complex->imagp[i] = pv->polarWindow[i].mag * sin(pv->polarWindow[i].phase);
    }
    
    inverseFFT(pv->complexFrame, buffer);
}

void fixPhase(PhaseVocoder* pv, PhaseVocoder* previousPV, float factor)
{
    int length = pv->halfWindowSize;
    for (int i = 0; i < length; i++)
    {
        float previousPhase = previousPV->polarWindow[i].phase;
        pv->polarWindow[i].phase = factor * (pv->polarWindow[i].phase - previousPhase) + previousPhase;
    }
}

float getMagnitude(float real, float imag)
{
    return sqrt(real * real + imag * imag);
}

double getPhase(float real, float imag)
{
    return atan2((double)imag, (double)real);
}