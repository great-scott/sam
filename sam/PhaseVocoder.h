//
//  PhaseVocoder.h
//  sam
//
//  Created by Scott McCoid on 2/1/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef sam_PhaseVocoder_h
#define sam_PhaseVocoder_h

#include "FFTFrame.h"

typedef struct t_polar
{
    float mag;
    float phase;
    
} Polar;


typedef struct t_pv
{
    FFT*      fft;
    FFTFrame* complexFrame;
    
    Polar*    polarWindow;
    Polar*    polarWindowMod;
    
    int       windowSize;               // it's possible that we want to have a different windowSize than FFT has at the moment
    int       halfWindowSize;
    
} PhaseVocoder;


// Constructor
PhaseVocoder* newPhaseVocoder(FFT* fft, int windowSize);

// Destructor
void freePhaseVocoder(PhaseVocoder* pv);

void analyze(PhaseVocoder* pv, PhaseVocoder* previousPV, float* buffer, int hopSize);

void synthesize(PhaseVocoder* pv, float* buffer);

void fixPhase(PhaseVocoder* pv, PhaseVocoder* previousPV, float factor);

float getMagnitude(float real, float imag);

double getPhase(float real, float imag);

#endif
