//
//  FFTManager.h
//  TRE
//
//  Created by Scott McCoid on 10/31/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#ifndef TRE_FFTManager_h
#define TRE_FFTManager_h

#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>

typedef struct t_polar
{ 
    float mag; 
    float phase;
} POLAR;

// A whole polar window
typedef struct t_polarWindow
{
    POLAR* buffer;
    POLAR* oldBuffer;
    int    length;
    
} POLAR_WINDOW;


typedef struct t_fftFrame
{
    COMPLEX_SPLIT   complexBuffer;
    UInt32          windowSize;
    vDSP_Length     log2n;
    UInt32          nOver2;
    float           normFactor;
    float*          lastPhase;
    POLAR_WINDOW*   polarWindow;
    POLAR_WINDOW*   polarWindowMod;
    
} FFT_FRAME;

typedef struct t_fft
{
    UInt32          fftLength;      // window size that we'll be taking FFT
    UInt32          windowLength;   // the actual window's length, only slightly confusing
    float*          window;
    float*          invWindow;      // the window for the inverse 
    FFTSetup        fftSetup;
    COMPLEX_SPLIT   outOfPlaceComplex;
} FFT;

typedef struct t_stftBuffer
{
    int     size;
    int     overlapAmount;
    float   max;
    FFT_FRAME** buffer;         // This is an array of FFT_FRAMEs
} STFT_BUFFER;

FFT* newFFT(UInt32 windowSize, bool zeroPad);    // zero pad if we're doing STFT
FFT_FRAME* newFFTFrame(UInt32 windowSize);
STFT_BUFFER* newSTFTBuffer(UInt32 windowSize, int overlapAmount, int *sizeOfBuffer, int length);

void freeFFT(FFT* fftToFree);
void freeFFTFrame(FFT_FRAME* frameToFree);
void freeSTFTBuffer(STFT_BUFFER* bufferToFree);

POLAR_WINDOW* newPolarWindow(int size);
void freePolarWindow(POLAR_WINDOW* windowToFree);
void pvUnwrapPhase(POLAR_WINDOW* window);
void pvFixPhase(const POLAR_WINDOW* previous, POLAR_WINDOW* current, float factor);

void computeFFT (FFT* instantiatedFFT, FFT_FRAME* fftFrameInstance, float* audioBuffer);
void computeSTFT(FFT* instantiatedFFT, STFT_BUFFER* fftFrameInstances, float* audioBuffer);
void computeSTFT_zeroPad(FFT* instantiatedFFT, STFT_BUFFER* stftBuffer, float* audioBuffer, int audioBufferLength);

void inverseFFT (FFT* instantiatedFFT, FFT_FRAME* fftFrameInstance, float* outputBuffer);

#endif
