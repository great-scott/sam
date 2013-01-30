//
//  STFT.h
//  sam
//
//  Created by Scott McCoid on 1/30/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//
//  This is essentially a container class for frames of FFT or PhaseVoc frames

#ifndef __sam__STFT__
#define __sam__STFT__

#include <iostream>
#include <vector>
#include "PhaseVocoder.h"

enum FrameType
{
    BASIC,
    PHASE_VOC
};

class STFT
{
    public:
        
        STFT(FFT* fftManager, int overlapAmount, int stftLength, FrameType type);
    
        ~STFT();
    
        void compute(float* buffer);
    
        // need method for changing overlap amount
    
    
    private:
    
        FFT*                        fft;
    
        int                         frameType;
        int                         overlap;
        int                         length;
    
        float*                      tempAudioBuffer;
    
        std::vector<PhaseVocoder>   phaseBuffer;
        std::vector<FFTFrame>       frameBuffer;

    
};

#endif /* defined(__sam__STFT__) */
