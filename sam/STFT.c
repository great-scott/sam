//
//  STFT.c
//  sam
//
//  Created by Scott McCoid on 2/3/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include <stdio.h>
#include "STFT.h"


STFT* newSTFT(FFT* fft, int windowSize, int overlapAmount, int stftLength, enum FrameType type)
{
    STFT* stft = (STFT *)malloc(sizeof(STFT));
    stft->fft = fft;
    stft->overlapAmount = overlapAmount;
    stft->length = stftLength;
    stft->windowSize = windowSize;
    
    stft->tempAudioBuffer = (float *)malloc(stft->windowSize * sizeof(float));
    stft->phaseBuffer = (PhaseVocoder **)malloc(stft->length * sizeof(PhaseVocoder *));
    
    for (int i = 0; i < stft->length; i++)
    {
        stft->phaseBuffer[i] = newPhaseVocoder(stft->fft, stft->windowSize);
    }
}

void freeSTFT(STFT* stft)
{
    for (int i = 0; i < stft->length; i++)
    {
        freePhaseVocoder(stft->phaseBuffer[i]);
    }
    
    free(stft->tempAudioBuffer);
    free(stft->phaseBuffer);
    free(stft);
}


// TODO: currently this cuts off the last frame because we're not zero padding
void compute(STFT* stft, float* buffer)
{
    int mod;
    int hopSamples = stft->windowSize / stft->overlapAmount;
    
    for (int pos = 0; pos < stft->length; pos++)
    {
        mod = (pos * hopSamples) % stft->windowSize;
        
        for (int i = 0; i < stft->windowSize; i++)
            stft->tempAudioBuffer[i] = buffer[(pos * hopSamples) + i];
        
        if (pos == 0)
            analyze(stft->phaseBuffer[pos], NULL, buffer, hopSamples);
        else
            analyze(stft->phaseBuffer[pos], stft->phaseBuffer[pos - 1], buffer, hopSamples);

    }
}





