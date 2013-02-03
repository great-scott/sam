//
//  STFT.h
//  sam
//
//  Created by Scott McCoid on 2/3/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#ifndef sam_STFT_h
#define sam_STFT_h

#include "FFT.h"
#include "PhaseVocoder.h"

enum FrameType
{
    BASIC,
    PHASE_VOC
};

typedef struct t_stft
{
    FFT*            fft;
    int             overlapAmount;
    int             length;
    int             windowSize;
    float*          tempAudioBuffer;
    
    PhaseVocoder**  phaseBuffer;
    
} STFT;

// Constructor
STFT* newSTFT(FFT* fft, int windowSize, int overlapAmount, int sftfLength, enum FrameType type);

// Destructor
void freeSTFT(STFT* stft);

//
void compute(STFT* stft, float* buffer);



#endif
