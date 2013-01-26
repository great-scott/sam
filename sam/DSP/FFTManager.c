//
//  FFTManager.c
//  TRE
//
//  Created by Scott McCoid on 10/31/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#include <stdio.h>
#include "FFTManager.h"

#define PI 3.14159265359
#define TWO_PI (2 * PI)

#define cmp_abs(x) ( sqrt( (x).re * (x).re + (x).im * (x).im ) )
#define __modulus(x) cmp_abs(x)
#define __phase(x) ( atan2((double)(x).im, (double)(x).re) )

int isPowerOfTwo(unsigned int x);
float getMagnitude(float real, float imag);
double getPhase(float real, float imag);

void deltaPhi(FFT_FRAME* fftFrame, float* previousPhase);
void sigmaPhi(FFT_FRAME* fftFrame, float* previousPhase);


#pragma mark __NEW_FFT__
/**********************************************************************************/

FFT* newFFT(UInt32 windowSize)
{
    FFT* fft = (FFT*)malloc(sizeof(FFT));
    if (fft == NULL)
        return NULL;
    
    if (isPowerOfTwo(windowSize) != 1)
        fft->fftLength = 256;
    else
        fft->fftLength = windowSize;
    
    // create fft setup
    vDSP_Length log2n = log2f(fft->fftLength);
    fft->fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    if (fft->fftSetup == 0)
        return NULL;
    
    // allocate memory for a window 
    fft->window = (float *)malloc(fft->fftLength * sizeof(float));
    vDSP_hann_window(fft->window, fft->fftLength, vDSP_HANN_DENORM);
    
    // hann
    //for (int i = 0; i < fft->fftLength; i++)
    //    fft->window[i] = 0.5 * (1 - cos((TWO_PI * i) / (fft->fftLength - 1)));
    
    fft->outOfPlaceComplex.realp = (float *)malloc((fft->fftLength / 2.0) * sizeof(float));
    fft->outOfPlaceComplex.imagp = (float *)malloc((fft->fftLength / 2.0) * sizeof(float));
    
    return fft;
}

void freeFFT(FFT* fftToFree)
{
    free(fftToFree->outOfPlaceComplex.realp);
    free(fftToFree->outOfPlaceComplex.imagp);
    vDSP_destroy_fftsetup(fftToFree->fftSetup);
    free(fftToFree->window);
    free(fftToFree);
}


#pragma mark __NEW_FFT_FRAME__

/*
 *  newFFTFrame allocates memory for a new FFT frame structure.
 *  This includes a complex buffer and other attributes of the frame.
 */
FFT_FRAME* newFFTFrame(UInt32 windowSize)
{
    FFT_FRAME* frame = (FFT_FRAME*)malloc(sizeof(FFT_FRAME));
    if (frame == NULL)
        return NULL;
    
    if (isPowerOfTwo(windowSize) != 1)
        frame->windowSize = 256;
    else 
        frame->windowSize = windowSize;
    
    frame->log2n = log2f(windowSize);
    frame->nOver2 = frame->windowSize / 2;
    
    // Lastly, allocate memory for complex buffer
    frame->complexBuffer.realp = (float *)malloc(frame->nOver2 * sizeof(float));
    frame->complexBuffer.imagp = (float *)malloc(frame->nOver2 * sizeof(float));
    frame->normFactor = 1.0 / (2 * windowSize);
    
    if (frame->complexBuffer.realp == NULL || frame->complexBuffer.imagp == NULL)
        return NULL;
    
    
    frame->polarWindow = newPolarWindow(windowSize / 2);
    frame->polarWindowMod = newPolarWindow(windowSize / 2);
    frame->lastPhase = (float *)malloc(frame->nOver2 * sizeof(float));
    memset(frame->lastPhase, 0.0, frame->nOver2 * sizeof(float));
    
    return frame;
}

void freeFFTFrame(FFT_FRAME* frameToFree)
{
    free(frameToFree->complexBuffer.realp);
    free(frameToFree->complexBuffer.imagp);
    free(frameToFree->lastPhase);
    freePolarWindow(frameToFree->polarWindow);
    freePolarWindow(frameToFree->polarWindowMod);
    free(frameToFree);
}


POLAR_WINDOW* newPolarWindow(int size)
{
    POLAR_WINDOW* polarWindow = (POLAR_WINDOW*)malloc(sizeof(POLAR_WINDOW));
    polarWindow->buffer = (POLAR*)malloc(size * sizeof(POLAR));
    polarWindow->oldBuffer = (POLAR*)malloc(size * sizeof(POLAR));
    
    memset(polarWindow->buffer, 0.0, 2 * size * sizeof(float));     // 2 * this because we're dealing with mag and phase
    memset(polarWindow->oldBuffer, 0.0, 2 * size * sizeof(float));
    polarWindow->length = size;
    
    return polarWindow;
}


void freePolarWindow(POLAR_WINDOW* windowToFree)
{
    free(windowToFree->buffer);
    free(windowToFree->oldBuffer);
    windowToFree->buffer = NULL;
    windowToFree->oldBuffer = NULL;
    windowToFree->length = 0;
    
    free(windowToFree);
    windowToFree = NULL;
}

/**********************************************************************************/

STFT_BUFFER* newSTFTBuffer(UInt32 windowSize, int overlapAmount, int *sizeOfBuffer, int length)
{
    int numColumns = floor(length / (windowSize / overlapAmount));
    float fractional = numColumns - (length / (windowSize / overlapAmount));
    
    if (fractional != 0)
    {
        // need to zero padd
    }
    
    // Allocate memory for the stft buffer
    STFT_BUFFER* stft = (STFT_BUFFER *)malloc(sizeof(STFT_BUFFER));
    if (stft == NULL)
        return NULL;
    
    // If stft buffer created, then set size and overlap amount properties
    stft->size = numColumns;
    stft->overlapAmount = overlapAmount;
    
    // Allocate memory for pointers to buffers
    stft->buffer = (FFT_FRAME **)malloc(numColumns * sizeof(FFT_FRAME *));
    if (stft->buffer == NULL)
        return NULL;
    
    // Allocate memory for each buffer
    for (int i = 0; i < numColumns; i++)
    {
        stft->buffer[i] = newFFTFrame(windowSize);        //(FFT_FRAME *)malloc(windowSize * sizeof(FFT_FRAME));
        if (stft->buffer[i] == NULL)
            return NULL;
    }
    
    *sizeOfBuffer = numColumns;
    
    stft->max = 0.0;
    
    // If everything goes smoothly, return pointer to stft buffer
    return stft;
    
}

void freeSTFTBuffer(STFT_BUFFER* bufferToFree)
{
    // first free all the frames
    for (int i = 0; i < bufferToFree->size; i++)
        freeFFTFrame(bufferToFree->buffer[i]);

    // free all the pointers to the frames
    free(bufferToFree->buffer);
    
    // lastly, free the stft buffer
    free(bufferToFree);
}


void computeFFT (FFT* instantiatedFFT, FFT_FRAME* fftFrameInstance, float* audioBuffer)
{
//    for (int i = 0; i < instantiatedFFT->fftLength; i++)
//        audioBuffer[i] = audioBuffer[i] * instantiatedFFT->window[i];
    
    // This applies the windowing
    //vDSP_vmul(audioBuffer, 1, instantiatedFFT->window, 1, audioBuffer, 1, instantiatedFFT->fftLength);
    
    
    
    // Do some data packing stuff
    vDSP_ctoz((COMPLEX*)audioBuffer, 2, &fftFrameInstance->complexBuffer, 1, fftFrameInstance->nOver2);
    
    // Actually perform the fft
    vDSP_fft_zrip(instantiatedFFT->fftSetup, &fftFrameInstance->complexBuffer, 1, fftFrameInstance->log2n, FFT_FORWARD);
    
    // Do some scaling
    vDSP_vsmul(fftFrameInstance->complexBuffer.realp, 1, &fftFrameInstance->normFactor, fftFrameInstance->complexBuffer.realp, 1, fftFrameInstance->nOver2);
    vDSP_vsmul(fftFrameInstance->complexBuffer.imagp, 1, &fftFrameInstance->normFactor, fftFrameInstance->complexBuffer.imagp, 1, fftFrameInstance->nOver2);
    
    // Zero out DC offset
    fftFrameInstance->complexBuffer.imagp[0] = 0.0;
}


void inverseFFT (FFT* instantiatedFFT, FFT_FRAME* fftFrameInstance, float* outputBuffer)
{
    
//    POLAR_WINDOW* window = fftFrameInstance->polarWindowMod;
//    const POLAR* p = (const POLAR*)window->buffer;
//    
//    COMPLEX_SPLIT *c = &fftFrameInstance->complexBuffer;
//    
//    for(int i = 0; i < window->length; i++)
//    {
//        c->realp[i] = p[i].mag * cos(p[i].phase);
//        c->imagp[i] = p[i].mag * sin(p[i].phase);
//    }
    // perform IFFT
    vDSP_fft_zrop(instantiatedFFT->fftSetup, &fftFrameInstance->complexBuffer, 1, &instantiatedFFT->outOfPlaceComplex, 1, fftFrameInstance->log2n, FFT_INVERSE);
    
    // The output signal is now in a split real form.  Use the  function vDSP_ztoc to get a split real vector. 
    vDSP_ztoc(&instantiatedFFT->outOfPlaceComplex, 1, (COMPLEX *)outputBuffer, 2, fftFrameInstance->nOver2);
    
    // This applies the windowing
    //vDSP_vmul(outputBuffer, 1, instantiatedFFT->window, 1, outputBuffer, 1, instantiatedFFT->fftLength);
    
//    for (int i = 0; i < instantiatedFFT->fftLength; i++)
//        outputBuffer[i] = outputBuffer[i] * instantiatedFFT->window[i];
}


/*
 *  computeSTFT computes the short time fourier transform
 *  overlap = the amount of overlap (so most likely 2 or 4)
 *
 */
void computeSTFT(FFT* instantiatedFFT, STFT_BUFFER* stftBuffer, float* audioBuffer)
{
    int mod;
    float *tempBuffer = (float *)malloc(instantiatedFFT->fftLength * sizeof(float));    
    int hopSamples = instantiatedFFT->fftLength / stftBuffer->overlapAmount;
    
    float mag, phi, delta;
    float scale = (float)(TWO_PI * hopSamples / instantiatedFFT->fftLength);
    float fac = (float)(44100.0 / (hopSamples * TWO_PI));
    
    for (int pos = 0; pos < stftBuffer->size; pos++)
    {
        FFT_FRAME* frame = stftBuffer->buffer[pos];
        POLAR_WINDOW* p = frame->polarWindow;
        
        FFT_FRAME* prevFrame = NULL;
        POLAR_WINDOW* prevPolar = NULL;
        if (pos > 0)
        {
            prevFrame = stftBuffer->buffer[pos - 1];
            prevPolar = prevFrame->polarWindow;
        }
            
        mod = (pos * hopSamples) % instantiatedFFT->fftLength;
        
        for (int i = 0; i < instantiatedFFT->fftLength; i++)
            tempBuffer[i] = audioBuffer[(pos * hopSamples) + i];
            //tempBuffer[(i + mod) % instantiatedFFT->fftLength] = audioBuffer[(pos * hopSamples) + i];
        
        computeFFT(instantiatedFFT, frame, tempBuffer);
        
        // calculate magnitude and phase and put in another array for now
        for (int i = 0; i < frame->windowSize / 2; i++)
        {
            //p->buffer[i].mag = getMagnitude(frame->complexBuffer.realp[i], frame->complexBuffer.imagp[i]);
            //p->buffer[i].phase = getPhase(frame->complexBuffer.realp[i], frame->complexBuffer.imagp[i]);
            
            mag = getMagnitude(frame->complexBuffer.realp[i], frame->complexBuffer.imagp[i]);
            phi = getPhase(frame->complexBuffer.realp[i], frame->complexBuffer.imagp[i]);
            
            if (prevPolar != NULL)
                delta = phi - prevPolar->buffer[i].phase;
            else
                delta = phi;
            
            while(delta > PI) delta -= (float)TWO_PI;
            while(delta < -PI) delta += (float)TWO_PI;
            
            p->buffer[i].phase = (delta + i * scale) * fac;
            p->buffer[i].mag = mag;
            
            if (p->buffer[i].mag > stftBuffer->max)
                stftBuffer->max = p->buffer[i].mag;
            
        }
        
        // make a copy
        memcpy(p->oldBuffer, p->buffer, p->length * sizeof(POLAR));
    }

    
    free(tempBuffer);
}


#pragma mark __UTIL__
int isPowerOfTwo (unsigned int x)
{
    return ((x != 0) && !(x & (x - 1)));
}

float getMagnitude(float real, float imag)
{
    return sqrt(real * real + imag * imag);
}

double getPhase(float real, float imag)
{
    return atan2((double)imag, (double)real);
}

void pvUnwrapPhase(POLAR_WINDOW* window)
{
    int length = window->length;
    POLAR* p = window->buffer;
    float x;
    
    for(int i = 0; i < length; i++ )
    {
        x = floor(fabs(p[i].phase / PI ) );
        if( p[i].phase < 0.0f ) 
            x *= -1.0f;
        p[i].phase -= x * PI;
    }
}

void pvFixPhase(const POLAR_WINDOW* previous, POLAR_WINDOW* current, float factor)
{
    int length = current->length;
    const POLAR* p = previous->buffer;
    const POLAR* r = previous->oldBuffer;
    POLAR* c = current->buffer;
    
    for (int i = 0; i < length; i++, p++, r++, c++)
        c->phase = factor * (c->phase - r->phase) + p->phase;
    //currentPhase = scale * (currentPhase - previousOldPhase) + previousCurrentPhase
}

void deltaPhi(FFT_FRAME* fftFrame, float* previousPhase)
{
    int i, k;
    float phi;
    
    // Start incrementing at index 1 to avoid DC offset
    for (k = 0, i = 1; i < fftFrame->nOver2; i++, k++)
    {   
        // Ok, here we're turning the realp values into magnitude values
        fftFrame->complexBuffer.realp[i] = sqrt(fftFrame->complexBuffer.realp[i] * fftFrame->complexBuffer.realp[i] + fftFrame->complexBuffer.imagp[i] * fftFrame->complexBuffer.imagp[i]);
        
        // Ok, here we're converting the imaginary values to phase values
        phi = atan2(fftFrame->complexBuffer.imagp[i], fftFrame->complexBuffer.realp[i]);
        fftFrame->complexBuffer.imagp[i] = phi - previousPhase[k];
        previousPhase[k] = phi;
        
        // Classic one-liners for bringing to the -pi and pi range
        while (fftFrame->complexBuffer.imagp[i] > PI) fftFrame->complexBuffer.imagp[i] -= TWO_PI;
        while (fftFrame->complexBuffer.imagp[i] < PI) fftFrame->complexBuffer.imagp[i] += TWO_PI;
    }
}


void sigmaPhi(FFT_FRAME* fftFrame, float* previousPhase)
{
    int i, k;
    float mag, phi;
    
    for (k = 0, i = 1; i < fftFrame->nOver2; i++, k++)
    {
        // Temporary variables to hold current values while we do some operations and whatnot
        mag = fftFrame->complexBuffer.realp[i];
        phi = fftFrame->complexBuffer.imagp[i] + previousPhase[k];
        
        previousPhase[k] = phi;
        
        // Converting back to real and imaginary components
        fftFrame->complexBuffer.realp[i] = (float)(mag * cos(phi));
        fftFrame->complexBuffer.imagp[i] = (float)(mag * sin(phi));
        
    }
}




//
//float delta, phi, fac, scale, mag;
//int hopSize = instantiatedFFT->fftLength / overlapAmount; 
//fac = (float) (hopSize * TWO_PI / 44100.0); 
//scale = 44100.0 / instantiatedFFT->fftLength;
//
////    for (int i = 1; i < fftFrameInstance->nOver2; i++)
////    {
////        //delta = (fftFrameInstance->complexBuffer.imagp[i] - i * scale) * fac;
////        delta = (fftFrameInstance->complexBuffer.imagp[i] - scale) * fac;
////        //phi = fftFrameInstance->lastPhase[i - 1] + delta;
////        phi = fftFrameInstance->lastPhase + delta;
////        //fftFrameInstance->lastPhase[i - 1] = phi;
////        fftFrameInstance->lastPhase = phi;
////        mag = fftFrameInstance->complexBuffer.realp[i];
////        
////        fftFrameInstance->complexBuffer.realp[i] = (float) (mag * cos(phi));
////        fftFrameInstance->complexBuffer.imagp[i] = (float) (mag * sin(phi));
////    }




//        for (int i = 1; i < instantiatedFFT->fftLength / 2; i++)
//        {
//            FFT_FRAME* frame = stftBuffer->buffer[pos];
//            mag = (float) sqrt(frame->complexBuffer.realp[i] * frame->complexBuffer.realp[i] + frame->complexBuffer.imagp[i] * frame->complexBuffer.imagp[i]);
//            phi = (float) atan2(frame->complexBuffer.imagp[i], frame->complexBuffer.realp[i]);
//            
//            //delta = phi - frame->lastPhase[i - 1];
//            delta = phi - frame->lastPhase;
//            //frame->lastPhase[i - 1] = phi;
//            frame->lastPhase = phi;
//            
//            while (delta > PI) delta -= (float) TWO_PI;
//            while (delta < -PI) delta += (float) TWO_PI;
//            
//            frame->complexBuffer.realp[i] = mag;
//            //frame->complexBuffer.imagp[i] = (delta + i * scale) * fac;
//            frame->complexBuffer.imagp[i] = (delta + scale) * fac;
//        }






