//
//  STFT.cpp
//  sam
//
//  Created by Scott McCoid on 1/30/13.
//  Copyright (c) 2013 Scott McCoid. All rights reserved.
//

#include "STFT.h"

STFT::STFT(FFT* fftManager, int overlapAmount, int stftLength, FrameType type)
{
    fft = fftManager;
    frameType = type;
    overlap = overlapAmount;
    length = stftLength;
    
    if (type == PHASE_VOC)
        phaseBuffer = std::vector<PhaseVocoder>(length);
    
    tempAudioBuffer = new float[fft->getWindowSize()];
}

STFT::~STFT()
{
    delete[] tempAudioBuffer;
}

// TODO: currently this cuts off the last frame because we're not zero padding
void STFT::compute(float* buffer)
{
    int mod;
    int hopSamples = fft->getWindowSize() / overlap;
    
    PhaseVocoder firstPv(fft);
    
    for (int pos = 0; pos < length; pos++)
    {
        mod = (pos * hopSamples) % fft->getWindowSize();
        for (int i = 0; i < fft->getWindowSize(); i++)
            tempAudioBuffer[i] = buffer[(pos * hopSamples) + i];
        
        PhaseVocoder* pv = new PhaseVocoder(fft);
        
        if (pos == 0)
            pv->analyze(buffer, firstPv, hopSamples);
        else
            pv->analyze(buffer, phaseBuffer[pos - 1], hopSamples);
        
        phaseBuffer[pos] = *pv;
    }
    
}