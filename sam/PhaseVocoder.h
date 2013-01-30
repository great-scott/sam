//
//  PhaseVocoder.h
//  sam
//
//  Created by Scott McCoid on 1/30/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//
//  This class represents all the methods / data associated with a frame of a phase vocoder
//  It mainly wraps up current FFT methods / data into a "neater" package
//  Instantiate an FFT object and pass that in the constructor, the class will take care of the
//  analysis and instantiating / deleting 
//  


#ifndef __sam__PhaseVocoder__
#define __sam__PhaseVocoder__

#include <iostream>
#include "FFT.h"
#include "FFTFrame.h"

typedef struct t_polar
{
    float mag;
    float phase;
} POLAR;


class PhaseVocoder
{
    public:
        // Constructor
        PhaseVocoder(FFT* fftManager);
    
        // Destructor
        ~PhaseVocoder();
    
        // PV Analysis
        void analyze(float* buffer, PhaseVocoder& previousPV);            // in both of these cases, buffer is a time domain signal
    
        // PV Synthesis
        void synthesize(float* buffer);
    
        const POLAR& operator[] (const int nIndex);
    
    private:
        // instance of fft
        FFT*      fft;
        FFTFrame* complexFrame;
    
        POLAR*    polarWindow;
        POLAR*    polarWindowMod;
    
    
        float getMagnitude(float real, float imag);
    
        double getPhase(float real, float imag);

    
};

#endif /* defined(__sam__PhaseVocoder__) */
